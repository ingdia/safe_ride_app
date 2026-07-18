import 'package:flutter/material.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';
import 'transport_analytics_screen.dart';

class ReportModel {
  final String title;
  final String subtitle;
  final bool isReady;

  const ReportModel({
    required this.title,
    required this.subtitle,
    required this.isReady,
  });
}

const List<ReportModel> _reports = [
  ReportModel(
    title: 'Daily Operations Report',
    subtitle: 'June 4, 2026',
    isReady: true,
  ),
  ReportModel(
    title: 'Weekly Performance Summary',
    subtitle: 'May 28 - Jun 3, 2026',
    isReady: true,
  ),
  ReportModel(
    title: 'Monthly Fleet Analysis',
    subtitle: 'May 2026',
    isReady: true,
  ),
  ReportModel(
    title: 'Safety Incidents Report',
    subtitle: 'Q2 2026',
    isReady: true,
  ),
];

class ReportsAnalyticsScreen extends StatelessWidget {
  const ReportsAnalyticsScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(
                  AdminUiSpacing.md,
                  AdminUiSpacing.sm,
                  AdminUiSpacing.md,
                  AdminUiSpacing.lg,
                ),
                child: HeaderTitleBlock(
                  title: 'Reports & Analytics',
                  subtitle: 'View performance metrics and insights',
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                AdminUiSpacing.lg,
                AdminUiSpacing.md,
                0,
              ),
              sliver: const SliverToBoxAdapter(
                child: _SectionLabel(title: "Today's Performance"),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminUiSpacing.md,
              ),
              sliver: SliverToBoxAdapter(child: _PerformanceGrid()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                AdminUiSpacing.lg,
                AdminUiSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TransportAnalyticsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.show_chart_rounded, size: 18),
                    label: const Text('View Transport Analytics Dashboard'),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                AdminUiSpacing.lg,
                AdminUiSpacing.md,
                0,
              ),
              sliver: const SliverToBoxAdapter(
                child: _SectionLabel(title: 'Available Reports'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AdminUiSpacing.md,
              ),
              sliver: SliverList.separated(
                itemCount: _reports.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AdminUiSpacing.sm),
                itemBuilder: (context, index) =>
                    _ReportCard(report: _reports[index]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                AdminUiSpacing.lg,
                AdminUiSpacing.md,
                0,
              ),
              sliver: const SliverToBoxAdapter(
                child: _SectionLabel(title: 'Recent Activity'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: const [
                    _ActivityRow(
                      dotColor: AdminUiColors.onTimeFg,
                      text: 'Bus #12 completed route ahead of schedule',
                      time: '8:45 AM',
                    ),
                    SizedBox(height: AdminUiSpacing.sm),
                    _ActivityRow(
                      dotColor: AdminUiColors.delayedFg,
                      text: 'Bus #07 delayed due to traffic',
                      time: '8:30 AM',
                    ),
                    SizedBox(height: AdminUiSpacing.sm),
                    _ActivityRow(
                      dotColor: AdminUiColors.infoFg,
                      text: 'All morning routes dispatched',
                      time: '7:00 AM',
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AdminUiSpacing.lg),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminUiSpacing.sm),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PerformanceGrid extends StatelessWidget {
  const _PerformanceGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AdminUiSpacing.sm,
      crossAxisSpacing: AdminUiSpacing.sm,
      childAspectRatio: 1.7,
      children: const [
        _MetricCard(
          icon: Icons.check_circle_rounded,
          iconColor: AdminUiColors.onTimeFg,
          value: '94%',
          label: 'On-Time Performance',
        ),
        _MetricCard(
          icon: Icons.timer_outlined,
          iconColor: AdminUiColors.primaryOrange,
          value: '3.2 min',
          label: 'Average Delay',
        ),
        _MetricCard(
          icon: Icons.error_outline_rounded,
          iconColor: AdminUiColors.delayedFg,
          value: '5',
          label: 'Total Incidents',
        ),
        _MetricCard(
          icon: Icons.trending_up_rounded,
          iconColor: AdminUiColors.infoFg,
          value: '156',
          label: 'Routes Completed',
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: AdminUiSpacing.sm),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AdminUiColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  report.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AdminUiColors.onTimeBg,
                  borderRadius: BorderRadius.circular(AdminUiRadii.chip),
                ),
                child: const Text(
                  'Ready',
                  style: TextStyle(
                    color: AdminUiColors.onTimeFg,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            report.subtitle,
            style: const TextStyle(
              color: AdminUiColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: AdminUiSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Download PDF'),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AdminUiColors.statCardBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.ios_share_rounded,
                  color: AdminUiColors.primaryOrange,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final Color dotColor;
  final String text;
  final String time;

  const _ActivityRow({
    required this.dotColor,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AdminUiSpacing.sm),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
          Text(
            time,
            style: const TextStyle(
              color: AdminUiColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
