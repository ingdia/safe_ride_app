import 'package:flutter/material.dart';

/// Shared color tokens pulled from the Figma design.
///
/// Every text/background pairing used across the app should be checked
/// against a 4.5:1 contrast ratio (WCAG AA) before use — see Task 1's
/// "Done" criteria.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE8790A); // amber/orange (on-brand)
  static const Color primaryDark = Color(0xFFC96406);

  static const Color background = Color(0xFFF7F5F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7E2DC);

  static const Color textPrimary = Color(0xFF1F2124); // ~15.5:1 on surface
  static const Color textSecondary = Color(0xFF5B5F66); // ~4.9:1 on surface

  static const Color success = Color(0xFF1E8A4C);
  static const Color error = Color(0xFFD1372B);
  static const Color warning = Color(0xFFB8790A);
}