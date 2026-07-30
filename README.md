# SafeRide 🚌

Eliminating parental anxiety with real-time school bus tracking and automated safety notifications for Kigali families.

---

## Overview

SafeRide is a Flutter mobile application that connects **parents**, **drivers**, and **school administrators** on a single platform to ensure every child's school commute is safe and transparent.

## Features

### For Parents
- Real-time bus location tracking
- Automated boarding/drop-off notifications
- Trip history and route stop visibility
- Notification centre for alerts and updates

### For Drivers
- Daily route and student manifest
- Student attendance marking (with offline support)
- SOS emergency alert button
- Route progress tracking

### For Admins
- Fleet and bus management
- Driver onboarding and approval
- Route creation and management
- Attendance reports and transport analytics
- System-wide notifications and emergency oversight

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 (Dart ^3.12) |
| State Management | Riverpod 3 + flutter_bloc |
| Backend | Firebase (Auth + Firestore) |
| Offline Storage | Hive |
| Connectivity | connectivity_plus |
| Charts | fl_chart |

---

## Project Structure

```
lib/
├── core/               # Routing, Firebase config, theme, utilities
├── features/
│   ├── auth/           # Login, register, forgot password
│   ├── parent/         # Parent dashboard, tracking, notifications
│   ├── driver/         # Route screen, attendance, SOS
│   └── admin/          # Dashboard, fleet, routes, analytics
└── shared/             # Enums, shared providers, global widgets
```

The project follows a **feature-first clean architecture** with `data / domain / presentation` layers per feature.

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.12
- A Firebase project with **Authentication** and **Firestore** enabled

### Setup

```bash
# 1. Clone the repo
git clone <repo-url>
cd safe_ride_app

# 2. Install dependencies
flutter pub get

# 3. Add your Firebase config
#    - Android: android/app/google-services.json
#    - iOS:     ios/Runner/GoogleService-Info.plist

# 4. Run the app
flutter run
```

---

## User Roles

| Role | Entry Point |
|---|---|
| Parent | `/parent/home` |
| Driver | `/driver/dashboard` |
| Admin | `/admin/shell` |

Role-based routing is handled automatically after login via `AppRouter.dashboardForRole(role)`.

---

## Running Tests

```bash
flutter test
```

Tests are located in `test/features/` organised by feature (auth, driver, admin, parent).

---

## Driver Real-Time Streams

The driver feature uses three Firestore `snapshots()` streams, all managed by `DriverStreamService` and exposed as Riverpod `StreamProvider.family` providers. Every stream opens a persistent WebSocket connection to Firestore and re-emits automatically whenever the underlying data changes — no polling, no manual refresh.

### How it works

```
Firestore document/collection write
        │
        ▼
  DriverStreamService          (data/datasources/driver_stream_service.dart)
  ├── routeDataStream(routeId)     → Stream<RouteData?>
  ├── alertsStream(routeId)        → Stream<List<DriverAlert>>
  └── studentsStream(routeId)      → Stream<List<Student>>
        │
        ▼
  Riverpod StreamProvider.family   (presentation/providers/driver_route_provider.dart)
  ├── routeDataStreamProvider(routeId)
  ├── driverAlertsStreamProvider(routeId)
  └── studentRosterStreamProvider(routeId)
        │
        ▼
  UI widgets rebuild automatically via ref.watch / ref.listen
```

| Stream | Firestore path | UI consumer |
|---|---|---|
| `routeDataStream` | `routes/{routeId}` | `_LiveSummaryCard` in Today's Route screen |
| `alertsStream` | `routes/{routeId}/alerts` | `DriverDashboardScreen` (snackbar via `ref.listen`) |
| `studentsStream` | `students` where `routeId == …` | `_LiveRosterBody` in Student Attendance screen |

`routeId` is resolved at runtime from the first document in the `routes` collection via `FirestoreDriverRepository.fetchRouteMetadata()`. When no Firestore route exists the app falls back to `MockDriverRepository` and streams are inactive.

### Required Firestore collection structure

Create the following documents in your Firebase project before testing. Document IDs can be anything — the app reads the first route document it finds.

**`routes/{routeId}`**
```json
{
  "name":          "Route A – Kigali North",
  "busId":         "bus_001",
  "driverId":      "driver_001",
  "status":        "scheduled",
  "scheduledTime": "07:45",
  "etaMinutes":    12,
  "stops": [
    {
      "order":        1,
      "name":         "Oak Street",
      "studentCount": 3,
      "time":         "7:45 AM",
      "status":       "upcoming",
      "isDestination": false
    },
    {
      "order":        2,
      "name":         "Maple Ave",
      "studentCount": 2,
      "time":         "7:55 AM",
      "status":       "upcoming",
      "isDestination": false
    },
    {
      "order":        3,
      "name":         "GS Kigali",
      "studentCount": 0,
      "time":         "8:10 AM",
      "status":       "upcoming",
      "isDestination": true
    }
  ]
}
```

**`routes/{routeId}/alerts/{alertId}`** (subcollection)
```json
{
  "title":     "Road closure",
  "message":   "Avoid Kimironko junction — use bypass road",
  "type":      "general",
  "routeId":   "{routeId}",
  "isRead":    false,
  "timestamp": <Firestore server timestamp>
}
```

Valid `type` values: `"general"` · `"arrival"` · `"sos"` (SOS shows a red urgent banner).

**`students/{studentId}`**
```json
{
  "name":     "Alice Uwimana",
  "stopName": "Oak Street",
  "grade":    "P3",
  "status":   "notBoarded",
  "routeId":  "{routeId}"
}
```

Valid `status` values: `"notBoarded"` · `"boarded"` · `"alighted"` / `"absent"`.

**`buses/{busId}`** (written by the driver app — no manual seed needed)
```json
{
  "busLocation": { "latitude": -1.9441, "longitude": 30.0619 },
  "lastUpdatedAt": <Firestore server timestamp>
}
```

### Firestore security rules (minimum for development)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Driver reads routes and their subcollections
    match /routes/{routeId} {
      allow read: if request.auth != null;
      match /alerts/{alertId}  { allow read: if request.auth != null; }
      match /attendance/{id}   { allow read, write: if request.auth != null; }
    }
    // Driver reads and writes student status
    match /students/{studentId} {
      allow read, write: if request.auth != null;
    }
    // Driver writes GPS location
    match /buses/{busId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

> **Note:** These rules allow any authenticated user to read/write all driver data. Tighten them with role-based claims before production.

---

## Manual Verification: Admin change → Driver app updates instantly

These steps confirm the end-to-end streaming pipeline works in a running app. You need two browser tabs open to the [Firebase Console](https://console.firebase.google.com) and the driver app running on a device or emulator.

### Prerequisites

1. Firestore seeded with at least one `routes/{routeId}` document and two `students/{studentId}` documents pointing to that `routeId` (see structure above).
2. Driver app running and logged in — confirm the Today's Route screen shows the live summary card (not the static fallback) and the Student Attendance screen shows the seeded students.

---

### Test 1 — Route document update reflects on Today's Route screen

**What it tests:** `routeDataStream` → `routeDataStreamProvider` → `_LiveSummaryCard`.

1. Open the driver app on the **Today's Route** tab.
2. Note the current route name and bus label shown in the summary card.
3. In the Firebase Console, navigate to `routes/{routeId}` and edit the `name` field to `"Route B – Test"`.
4. **Expected:** The summary card header updates to `Route B – Test` within 1–2 seconds, with no app restart or manual refresh.
5. Edit `status` to `"inProgress"` and `etaMinutes` to `5`.
6. **Expected:** The ETA stat in the card changes to `5 min` instantly.
7. Restore the original values.

---

### Test 2 — New alert document triggers dashboard snackbar

**What it tests:** `alertsStream` → `driverAlertsStreamProvider` → `ref.listen` in `DriverDashboardScreen`.

1. Navigate the driver app to the **Home (Dashboard)** tab.
2. In the Firebase Console, open `routes/{routeId}/alerts` and click **Add document**.
3. Set the document fields:
   ```
   title     → "School gate closed"
   message   → "Use the side entrance on Kimironko Road"
   type      → "general"
   routeId   → {routeId}
   isRead    → false
   timestamp → (click the timestamp option and choose server timestamp)
   ```
4. Save the document.
5. **Expected:** A floating snackbar appears on the driver dashboard within 1–2 seconds showing the title and message. No tap or refresh required.
6. Add a second alert with `type` set to `"sos"`.
7. **Expected:** A red urgent snackbar appears (10-second duration) with a warning icon.
8. Verify that navigating away and back to the dashboard does **not** re-show already-seen alerts (seen IDs are tracked in `_seenAlertIdsProvider` for the session).

---

### Test 3 — Student roster change reflects on Attendance screen

**What it tests:** `studentsStream` → `studentRosterStreamProvider` → `_LiveRosterBody`.

1. Navigate the driver app to the **Attendance** tab. Confirm the student list shows the seeded students and the green **● Live roster** badge is visible.
2. **Add a student mid-trip:** In the Firebase Console, create a new document in `students/` with:
   ```
   name     → "Bob Mugisha"
   stopName → "Maple Ave"
   grade    → "P4"
   status   → "notBoarded"
   routeId  → {routeId}
   ```
3. **Expected:** Bob Mugisha appears in the Maple Ave stop group on the attendance screen within 1–2 seconds.
4. **Remove a student mid-trip:** Delete the document you just created from the Firebase Console.
5. **Expected:** Bob Mugisha disappears from the list within 1–2 seconds.
6. **Verify attendance marks are preserved:** Mark an existing student as **Boarded** in the app. Then edit that student's `stopName` field in the Firebase Console.
7. **Expected:** The student's stop group updates to the new stop name, but their **Boarded** status is preserved (local attendance mark wins over the Firestore roster update).

---

### Test 4 — Offline fallback: no Firestore route

**What it tests:** Mock fallback path when `FirestoreDriverRepository` returns empty data.

1. Delete the `routes/{routeId}` document from the Firebase Console (or use a fresh Firebase project with no data).
2. Restart the driver app.
3. **Expected:** The app loads successfully using `MockDriverRepository` — the Today's Route screen shows the static summary card (no live badge), and the Attendance screen shows mock students. No crash or error screen.
4. Re-create the route document.
5. **Expected:** After a hot restart the app switches back to live Firestore data.
