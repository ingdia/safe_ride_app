import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminNavigationProvider =
    NotifierProvider<AdminNavigationNotifier, int>(
      AdminNavigationNotifier.new,
    );

class AdminNavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void selectTab(int index) => state = index;
}
