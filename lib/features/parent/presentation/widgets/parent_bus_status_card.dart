import 'package:flutter/material.dart';

import 'parent_ui_constants.dart';

class ParentBusStatusCard extends StatelessWidget {
  const ParentBusStatusCard({
    super.key,
    required this.childName,
    required this.busNumber,
    required this.status,
    required this.currentStop,
    required this.nextStop,
    required this.eta,
    required this.stopsAway,
    required this.progress,
    this.isOnTime = true,
  });

  final String childName;
  final String busNumber;
  final String status;
  final String currentStop;
  final String nextStop;
  final String eta;
  final int stopsAway;
  final double progress;
  final bool isOnTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ParentUiColors.orange, ParentUiColors.darkOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ParentUiRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.12),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(ParentUiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            busNumber: busNumber,
            childName: childName,
            status: status,
            isOnTime: isOnTime,
          ),
          const SizedBox(height: ParentUiSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.35),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: ParentUiSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 330;

              if (isSmall) {
                return Column(
                  children: [
                    _InfoTile(
                      icon: Icons.location_on_outlined,
                      title: 'Current stop',
                      value: currentStop,
                    ),
                    const SizedBox(height: ParentUiSpacing.sm),
                    _InfoTile(
                      icon: Icons.flag_outlined,
                      title: 'Next stop',
                      value: nextStop,
                    ),
                    const SizedBox(height: ParentUiSpacing.sm),
                    _InfoTile(
                      icon: Icons.schedule_outlined,
                      title: 'ETA',
                      value: eta,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.location_on_outlined,
                      title: 'Current stop',
                      value: currentStop,
                    ),
                  ),
                  const SizedBox(width: ParentUiSpacing.sm),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.flag_outlined,
                      title: 'Next stop',
                      value: nextStop,
                    ),
                  ),
                  const SizedBox(width: ParentUiSpacing.sm),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.schedule_outlined,
                      title: 'ETA',
                      value: eta,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: ParentUiSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: ParentUiSpacing.md,
              vertical: ParentUiSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(ParentUiRadius.md),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Text(
              '$stopsAway stops away from your child',
              textAlign: TextAlign.center,
              style: ParentUiTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.busNumber,
    required this.childName,
    required this.status,
    required this.isOnTime,
  });

  final String busNumber;
  final String childName;
  final String status;
  final bool isOnTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.directions_bus_rounded,
            color: ParentUiColors.orange,
            size: 28,
          ),
        ),
        const SizedBox(width: ParentUiSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                busNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ParentUiTextStyles.heading.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                childName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ParentUiTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOnTime ? Icons.check_circle_rounded : Icons.warning_rounded,
                size: 15,
                color: isOnTime
                    ? ParentUiColors.success
                    : ParentUiColors.warning,
              ),
              const SizedBox(width: 4),
              Text(
                status,
                style: ParentUiTextStyles.caption.copyWith(
                  color: isOnTime
                      ? ParentUiColors.success
                      : ParentUiColors.warning,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ParentUiSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(ParentUiRadius.sm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: ParentUiSpacing.xs),
          Text(
            title,
            style: ParentUiTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ParentUiTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
