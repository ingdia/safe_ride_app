import 'package:flutter/material.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';

enum StopProgress { completed, current, upcoming }

class RouteStopDisplay {
  final int order;
  final String name;
  final int studentCount;
  final StopProgress progress;

  const RouteStopDisplay({
    required this.order,
    required this.name,
    required this.studentCount,
    required this.progress,
  });
}

const List<RouteStopDisplay> _liveStops = [
  RouteStopDisplay(
    order: 1,
    name: 'Oak Street',
    studentCount: 3,
    progress: StopProgress.completed,
  ),
  RouteStopDisplay(
    order: 2,
    name: 'Maple Avenue',
    studentCount: 2,
    progress: StopProgress.current,
  ),
  RouteStopDisplay(
    order: 3,
    name: 'Pine Road',
    studentCount: 4,
    progress: StopProgress.upcoming,
  ),
  RouteStopDisplay(
    order: 4,
    name: 'Elm Court',
    studentCount: 2,
    progress: StopProgress.upcoming,
  ),
  RouteStopDisplay(
    order: 5,
    name: 'Cedar Lane',
    studentCount: 5,
    progress: StopProgress.upcoming,
  ),
];

class LiveMapScreen extends StatelessWidget {
  const LiveMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                child: HeaderTitleBlock(
                  title: 'Live Map',
                  subtitle: 'Real-time bus tracking',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AdminUiColors.statCardBackground,
                    borderRadius: BorderRadius.circular(AdminUiRadii.card),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(AdminUiSpacing.lg),
                      decoration: BoxDecoration(
                        color: AdminUiColors.cardBackground,
                        borderRadius: BorderRadius.circular(AdminUiRadii.card),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: AdminUiColors.primaryOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.navigation_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: AdminUiSpacing.sm),
                          const Text(
                            'Interactive Map View',
                            style: TextStyle(
                              color: AdminUiColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'GPS tracking visualization',
                            style: TextStyle(
                              color: AdminUiColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                AdminUiSpacing.sm,
                AdminUiSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Route Stops',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_liveStops.length} stops',
                      style: const TextStyle(
                        color: AdminUiColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverList.separated(
                itemCount: _liveStops.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AdminUiSpacing.sm),
                itemBuilder: (context, index) =>
                    _StopRow(stop: _liveStops[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  final RouteStopDisplay stop;

  const _StopRow({required this.stop});

  @override
  Widget build(BuildContext context) {
    final isCurrent = stop.progress == StopProgress.current;

    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(
          color: isCurrent ? AdminUiColors.primaryOrange : AdminUiColors.borderSubtle,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCurrent
                  ? AdminUiColors.primaryOrange
                  : AdminUiColors.statCardBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${stop.order}',
                style: TextStyle(
                  color: isCurrent ? Colors.white : AdminUiColors.primaryOrange,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: AdminUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AdminUiColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${stop.studentCount} students',
                      style: const TextStyle(
                        color: AdminUiColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _ProgressChip(progress: stop.progress),
        ],
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  final StopProgress progress;

  const _ProgressChip({required this.progress});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (progress) {
      case StopProgress.completed:
        bg = AdminUiColors.onTimeBg;
        fg = AdminUiColors.onTimeFg;
        label = 'Completed';
        break;
      case StopProgress.current:
        bg = AdminUiColors.statCardBackground;
        fg = AdminUiColors.primaryOrange;
        label = 'Current';
        break;
      case StopProgress.upcoming:
        bg = AdminUiColors.divider;
        fg = AdminUiColors.textSecondary;
        label = 'Upcoming';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AdminUiRadii.chip),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
