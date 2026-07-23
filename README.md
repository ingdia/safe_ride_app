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
