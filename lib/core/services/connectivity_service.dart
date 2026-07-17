import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();

  Stream<bool> get onlineStream => _connectivity.onConnectivityChanged
      .map((results) => _isOnline(results));

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  bool _isOnline(List<ConnectivityResult> results) => isOnlineFromResults(results);

  /// Exposed for testing — maps a result list to a boolean online status.
  bool isOnlineFromResults(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
