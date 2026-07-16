import 'package:flutter/material.dart';
import 'admin_ui_constants.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool onDark;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AdminUiSpacing.md,
        vertical: AdminUiSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminUiRadii.statCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AdminUiColors.statCardBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AdminUiColors.primaryOrange),
          ),
          const SizedBox(height: AdminUiSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: AdminUiColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AdminUiColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class StatRow extends StatelessWidget {
  final List<StatCard> cards;

  const StatRow({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minCardWidth = 100.0;
        final perCardWidth =
            (constraints.maxWidth - AdminUiSpacing.sm * (cards.length - 1)) /
                cards.length;
        final wide = perCardWidth >= minCardWidth;

        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i != 0) const SizedBox(width: AdminUiSpacing.sm),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i != 0) const SizedBox(width: AdminUiSpacing.sm),
                SizedBox(width: minCardWidth, child: cards[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}
