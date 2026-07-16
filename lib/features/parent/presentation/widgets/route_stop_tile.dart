import 'package:flutter/material.dart';

import 'parent_ui_constants.dart';

class RouteStopTile extends StatelessWidget {
  const RouteStopTile({
    super.key,
    required this.stopName,
    required this.time,
    required this.status,
    required this.position,
    required this.isLast,
  });

  final String stopName;
  final String time;
  final RouteStopStatus status;
  final int position;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final style = _styleFromStatus(status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: style.circleColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: style.borderColor, width: 2),
                ),
                child: Center(
                  child: status == RouteStopStatus.completed
                      ? const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.white,
                        )
                      : Text(
                          '$position',
                          style: ParentUiTextStyles.caption.copyWith(
                            color: style.numberColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: style.lineColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: ParentUiSpacing.md),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : ParentUiSpacing.md),
              padding: const EdgeInsets.all(ParentUiSpacing.md),
              decoration: parentCardDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stopName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ParentUiTextStyles.body.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          style.label,
                          style: ParentUiTextStyles.caption.copyWith(
                            color: style.labelColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: ParentUiSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ParentUiSpacing.sm,
                      vertical: ParentUiSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: style.badgeColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      time,
                      style: ParentUiTextStyles.caption.copyWith(
                        color: style.badgeTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _RouteStopStyle _styleFromStatus(RouteStopStatus status) {
    switch (status) {
      case RouteStopStatus.completed:
        return const _RouteStopStyle(
          label: 'Completed',
          circleColor: ParentUiColors.success,
          borderColor: ParentUiColors.success,
          numberColor: Colors.white,
          lineColor: ParentUiColors.success,
          labelColor: ParentUiColors.success,
          badgeColor: Color(0xFFE8F8EE),
          badgeTextColor: ParentUiColors.success,
        );

      case RouteStopStatus.current:
        return const _RouteStopStyle(
          label: 'Current stop',
          circleColor: ParentUiColors.orange,
          borderColor: ParentUiColors.orange,
          numberColor: Colors.white,
          lineColor: ParentUiColors.border,
          labelColor: ParentUiColors.orange,
          badgeColor: ParentUiColors.lightOrange,
          badgeTextColor: ParentUiColors.darkOrange,
        );

      case RouteStopStatus.upcoming:
        return const _RouteStopStyle(
          label: 'Upcoming',
          circleColor: Colors.white,
          borderColor: ParentUiColors.border,
          numberColor: ParentUiColors.textGrey,
          lineColor: ParentUiColors.border,
          labelColor: ParentUiColors.textGrey,
          badgeColor: Color(0xFFF3F4F6),
          badgeTextColor: ParentUiColors.textGrey,
        );
    }
  }
}

enum RouteStopStatus { completed, current, upcoming }

class _RouteStopStyle {
  const _RouteStopStyle({
    required this.label,
    required this.circleColor,
    required this.borderColor,
    required this.numberColor,
    required this.lineColor,
    required this.labelColor,
    required this.badgeColor,
    required this.badgeTextColor,
  });

  final String label;
  final Color circleColor;
  final Color borderColor;
  final Color numberColor;
  final Color lineColor;
  final Color labelColor;
  final Color badgeColor;
  final Color badgeTextColor;
}
