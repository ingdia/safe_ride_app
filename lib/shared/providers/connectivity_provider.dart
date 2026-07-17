import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>(
  (_) => ConnectivityService(),
);

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final service = ref.read(connectivityServiceProvider);
  yield await service.isOnline;
  yield* service.onlineStream;
});
