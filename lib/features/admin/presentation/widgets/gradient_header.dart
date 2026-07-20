import 'package:flutter/material.dart';
import 'admin_ui_constants.dart';

class GradientHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GradientHeader({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          padding ??
          const EdgeInsets.fromLTRB(
            AdminUiSpacing.md,
            AdminUiSpacing.lg,
            AdminUiSpacing.md,
            AdminUiSpacing.lg,
          ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AdminUiColors.primaryOrange,
            AdminUiColors.primaryOrangeDark,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: child,
    );
  }
}

class HeaderTitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final String backLabel;

  const HeaderTitleBlock({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.backLabel = 'Back to Dashboard',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null) ...[
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(8),
            hoverColor: Colors.white.withValues(alpha: 0.1),
            mouseCursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    backLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AdminUiSpacing.sm),
        ],
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
