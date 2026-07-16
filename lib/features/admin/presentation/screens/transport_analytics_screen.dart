import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_provider.dart';
import '../providers/on_time_performance_provider.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/analytics_bar_chart.dart';
import '../widgets/analytics_line_chart.dart';
import '../widgets/gradient_header.dart';

class TransportAnalyticsScreen extends ConsumerWidget {
  const TransportAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onTimeSeries = ref.watch(onTimePerformanceProvider);
    final attendanceRates = ref.watch(dailyAttendanceRatesProvider);

    final onTimeAverage = onTimeSeries.isEmpty
        ? 0.0
        : onTimeSeries.map((e) => e.onTimePercent).reduce((a, b) => a + b) /
            onTimeSeries.length;
    final attendanceAverage = attendanceRates.isEmpty
        ? 0.0
        : attendanceRates.map((e) => e.ratePercent).reduce((a, b) => a + b) /
            attendanceRates.length;

    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                padding: const EdgeInsets.fromLTRB(
                  AdminUiSpacing.md,
                  AdminUiSpacing.sm,
                  AdminUiSpacing.md,
                  AdminUiSpacing.lg,
                ),
                child: HeaderTitleBlock(
                  title: 'Transport Analytics',
                  subtitle: 'On-time performance and attendance trends',
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _AnalyticsCard(
                    title: 'On-Time Performance',
                    trailing: '${onTimeAverage.round()}% avg',
                    child: OnTimePerformanceChart(
                      dates: [for (final e in onTimeSeries) e.date],
                      values: [for (final e in onTimeSeries) e.onTimePercent],
                    ),
                  ),
                  const SizedBox(height: AdminUiSpacing.md),
                  _AnalyticsCard(
                    title: 'Daily Attendance Rates',
                    trailing: '${attendanceAverage.round()}% avg',
                    child: DailyAttendanceChart(
                      dates: [for (final e in attendanceRates) e.date],
                      values: [for (final e in attendanceRates) e.ratePercent],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String trailing;
  final Widget child;

  const _AnalyticsCard({
    required this.title,
    required this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: AdminUiSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AdminUiColors.statCardBackground,
                  borderRadius: BorderRadius.circular(AdminUiRadii.chip),
                ),
                child: Text(
                  trailing,
                  style: const TextStyle(
                    color: AdminUiColors.primaryOrangeDark,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminUiSpacing.md),
          child,
        ],
      ),
    );
  }
}
