import 'package:flutter/material.dart';

class AdminUiColors {
  AdminUiColors._();

  static const Color primaryOrange = Color(0xFFF97316);
  static const Color primaryOrangeDark = Color(0xFFC2410C);
  static const Color primaryOrangeLight = Color(0xFFFFA94D);

  static const Color scaffoldBackground = Color(0xFFF7F7F9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color statCardBackground = Color(0xFFFFF3E6);

  static const Color onTimeBg = Color(0xFFE7F7EE);
  static const Color onTimeFg = Color(0xFF1E9E5A);
  static const Color delayedBg = Color(0xFFFFF3E0);
  static const Color delayedFg = Color(0xFFE08A00);
  static const Color infoBg = Color(0xFFE8F1FF);
  static const Color infoFg = Color(0xFF2F6FED);

  static const Color textPrimary = Color(0xFF1F2430);
  static const Color textSecondary = Color(0xFF7C8393);
  static const Color textOnDark = Color(0xFFFFFFFF);

  static const Color borderSubtle = Color(0xFFF1D9B8);
  static const Color divider = Color(0xFFECECEF);
}

class AdminUiRadii {
  AdminUiRadii._();

  static const double card = 16;
  static const double chip = 20;
  static const double button = 14;
  static const double statCard = 18;
}

class AdminUiSpacing {
  AdminUiSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AdminTheme {
  AdminTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AdminUiColors.scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AdminUiColors.primaryOrange,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AdminUiColors.textPrimary,
        displayColor: AdminUiColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AdminUiColors.textOnDark,
      ),
      cardTheme: CardThemeData(
        color: AdminUiColors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminUiRadii.card),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(
            AdminUiColors.primaryOrange,
          ),
          foregroundColor: const WidgetStatePropertyAll(
            AdminUiColors.textOnDark,
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AdminUiSpacing.lg, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminUiRadii.button),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withValues(alpha: 0.16);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return Colors.black.withValues(alpha: 0.08);
            }
            return null;
          }),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) return 4;
            return 0;
          }),
          mouseCursor: const WidgetStatePropertyAll(
            SystemMouseCursors.click,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(
            AdminUiColors.primaryOrange,
          ),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AdminUiColors.primaryOrange),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AdminUiSpacing.lg, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdminUiRadii.button),
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AdminUiColors.primaryOrange.withValues(alpha: 0.16);
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return AdminUiColors.primaryOrange.withValues(alpha: 0.08);
            }
            return null;
          }),
          mouseCursor: const WidgetStatePropertyAll(
            SystemMouseCursors.click,
          ),
        ),
      ),
    );
  }
}
