import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps [Connectivity] from `connectivity_plus` and exposes a simple
/// boolean online/offline API to the rest of the app.
///
/// Implementation is added in the next commit on this branch.
/// The provider layer ([connectivityProvider]) depends on [isOnline] and
/// [onlineStream], so both are declared here to keep the project compiling.
class ConnectivityService {
  // TODO(offline-sync): inject Connectivity for testability
  // TODO(offline-sync): implement isOnline
  // TODO(offline-sync): implement onlineStream
  // TODO(offline-sync): implement isOnlineFromResults helper

  /// Returns the current online status as a one-shot [Future].
  Future<bool> get isOnline async => true;

  /// Emits `true`/`false` whenever the network state changes.
  Stream<bool> get onlineStream => const Stream.empty();

  /// Maps a raw [ConnectivityResult] list to a boolean.
  /// Exposed for unit testing without hitting the platform channel.
  bool isOnlineFromResults(List<ConnectivityResult> results) => true;
}
