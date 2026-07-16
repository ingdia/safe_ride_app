import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/parent/presentation/screens/parent_navigation_shell.dart';
import 'features/parent/presentation/widgets/parent_ui_constants.dart';

void main() {
  runApp(const ProviderScope(child: SafeRideApp()));
}

class SafeRideApp extends StatelessWidget {
  const SafeRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: ParentUiColors.orange),
        scaffoldBackgroundColor: ParentUiColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: ParentUiColors.background,
          foregroundColor: ParentUiColors.textDark,
          elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: ParentUiColors.lightOrange,
          labelTextStyle: WidgetStateProperty.all(
            ParentUiTextStyles.caption.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      home: const ParentNavigationShell(),
    );
  }
}
