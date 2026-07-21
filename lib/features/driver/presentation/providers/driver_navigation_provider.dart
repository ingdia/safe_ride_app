import 'package:flutter_riverpod/flutter_riverpod.dart';

final driverNavigationProvider =
    NotifierProvider<DriverNavigationNotifier, int>(
      DriverNavigationNotifier.new,
    );

class DriverNavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void selectTab(int index) => state = index;
}
