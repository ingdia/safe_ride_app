import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_ride_app/core/services/connectivity_service.dart';

/// Tests the pure mapping logic inside ConnectivityService without hitting
/// the real platform channel.
void main() {
  group('ConnectivityService._isOnline mapping', () {
    // Access the private helper via a thin subclass exposed only in tests.
    late _TestableConnectivityService service;

    setUp(() => service = _TestableConnectivityService());

    test('returns false when only ConnectivityResult.none is present', () {
      expect(service.testIsOnline([ConnectivityResult.none]), isFalse);
    });

    test('returns true when wifi is present', () {
      expect(service.testIsOnline([ConnectivityResult.wifi]), isTrue);
    });

    test('returns true when mobile is present', () {
      expect(service.testIsOnline([ConnectivityResult.mobile]), isTrue);
    });

    test('returns true when ethernet is present', () {
      expect(service.testIsOnline([ConnectivityResult.ethernet]), isTrue);
    });

    test('returns true when mixed results include a non-none type', () {
      expect(
        service.testIsOnline([ConnectivityResult.none, ConnectivityResult.wifi]),
        isTrue,
      );
    });

    test('returns false for an empty result list', () {
      expect(service.testIsOnline([]), isFalse);
    });
  });
}

/// Thin subclass that exposes the private `_isOnline` helper for unit testing.
class _TestableConnectivityService extends ConnectivityService {
  bool testIsOnline(List<ConnectivityResult> results) =>
      isOnlineFromResults(results);
}
