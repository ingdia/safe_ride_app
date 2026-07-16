import 'package:flutter/material.dart';

class ParentUiColors {
  const ParentUiColors._();

  static const Color orange = Color(0xFFFF8A00);
  static const Color darkOrange = Color(0xFFE86F00);
  static const Color lightOrange = Color(0xFFFFF4E3);
  static const Color background = Color(0xFFFFFBF4);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF1F2933);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color border = Color(0xFFF1D9B8);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color blue = Color(0xFF2563EB);
  static const Color textSecondary = Color(0xFF6B7280);
}

class ParentUiSpacing {
  const ParentUiSpacing._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class ParentUiRadius {
  const ParentUiRadius._();

  static const double sm = 12;
  static const double md = 18;
  static const double lg = 24;
  static const double xl = 30;
}

class ParentUiTextStyles {
  const ParentUiTextStyles._();

  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: ParentUiColors.textDark,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: ParentUiColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ParentUiColors.textDark,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ParentUiColors.textGrey,
  );
}

BoxDecoration parentCardDecoration({
  Color color = ParentUiColors.card,
  double radius = ParentUiRadius.md,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: ParentUiColors.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
