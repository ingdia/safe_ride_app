import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/emergency_alert.dart';
import '../../data/repositories/emergency_repository_impl.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class SosState {
  const SosState();
}

class SosIdle extends SosState {
  const SosIdle();
}

class SosLoading extends SosState {
  const SosLoading();
}

class SosSuccess extends SosState {
  const SosSuccess(this.alert);
  final EmergencyAlert alert;
}

class SosError extends SosState {
  const SosError(this.message);
  final String message;
}

class SosCancelled extends SosState {
  const SosCancelled();
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SosNotifier extends Notifier<SosState> {
  @override
  SosState build() => const SosIdle();

  Future<void> triggerSos({
    required String driverName,
    required String vehicle,
    required EmergencyType emergencyType,
  }) async {
    state = const SosLoading();
    try {
      final repo = ref.read(emergencyRepositoryProvider);
      final alert = await repo.triggerSos(
        driverName: driverName,
        vehicle: vehicle,
        emergencyType: emergencyType,
      );
      state = SosSuccess(alert);
    } on EmergencyException catch (e) {
      state = SosError(e.message);
    }
  }

  void cancel() => state = const SosCancelled();

  void reset() => state = const SosIdle();
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final sosProvider = NotifierProvider<SosNotifier, SosState>(
  SosNotifier.new,
);
