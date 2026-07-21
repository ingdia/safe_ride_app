import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/emergency_alert.dart';
import '../../data/repositories/emergency_repository_impl.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class AlertsState {
  const AlertsState();
}

class AlertsInitial extends AlertsState {
  const AlertsInitial();
}

class AlertsLoading extends AlertsState {
  const AlertsLoading();
}

class AlertsLoaded extends AlertsState {
  const AlertsLoaded(this.alerts);
  final List<EmergencyAlert> alerts;
}

class AlertsError extends AlertsState {
  const AlertsError(this.message);
  final String message;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AlertsNotifier extends Notifier<AlertsState> {
  @override
  AlertsState build() => const AlertsInitial();

  Future<void> loadAlerts() async {
    state = const AlertsLoading();
    try {
      final repo = ref.read(emergencyRepositoryProvider);
      final alerts = await repo.fetchAlerts();
      state = AlertsLoaded(alerts);
    } on EmergencyException catch (e) {
      state = AlertsError(e.message);
    }
  }

  Future<void> acknowledgeAlert(String alertId) async {
    final current = state;
    if (current is! AlertsLoaded) return;
    try {
      final repo = ref.read(emergencyRepositoryProvider);
      final updated = await repo.acknowledgeAlert(alertId);
      final newList = current.alerts
          .map<EmergencyAlert>((a) => a.id == alertId ? updated : a)
          .toList();
      state = AlertsLoaded(newList);
    } on EmergencyException catch (e) {
      state = AlertsError(e.message);
    }
  }

  Future<void> resolveAlert(String alertId) async {
    final current = state;
    if (current is! AlertsLoaded) return;
    try {
      final repo = ref.read(emergencyRepositoryProvider);
      final updated = await repo.resolveAlert(alertId);
      final newList = current.alerts
          .map<EmergencyAlert>((a) => a.id == alertId ? updated : a)
          .toList();
      state = AlertsLoaded(newList);
    } on EmergencyException catch (e) {
      state = AlertsError(e.message);
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final alertsProvider = NotifierProvider<AlertsNotifier, AlertsState>(
  AlertsNotifier.new,
);
