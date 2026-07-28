import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps [Connectivity] from `connectivity_plus` and exposes a simple
/// boolean online/offline API to the rest of the app.
///
/// Accepts an optional [Connectivity] instance so tests can inject a fake
/// without hitting the real platform channel.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Returns the current online status as a one-shot [Future].
  ///
  /// Calls [Connectivity.checkConnectivity] and maps the result list through
  /// [isOnlineFromResults].
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return isOnlineFromResults(results);
  }

  /// Emits `true` when the device comes online and `false` when it goes
  /// offline, re-emitting on every network state change.
  ///
  /// Backed by [Connectivity.onConnectivityChanged], which fires whenever
  /// the platform reports a connectivity change.
  Stream<bool> get onlineStream =>
      _connectivity.onConnectivityChanged.map(isOnlineFromResults);

  /// Maps a raw [ConnectivityResult] list to a boolean online status.
  ///
  /// Returns `true` when at least one result is not [ConnectivityResult.none].
  /// Exposed as a non-private method so tests can exercise the mapping logic
  /// directly via a thin subclass without touching the platform channel.
  bool isOnlineFromResults(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
