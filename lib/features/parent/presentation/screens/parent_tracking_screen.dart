import 'package:flutter/material.dart';

import '../widgets/parent_ui_constants.dart';
import '../widgets/route_stop_tile.dart';

class ParentTrackingScreen extends StatelessWidget {
  const ParentTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 600
                ? ParentUiSpacing.xl
                : ParentUiSpacing.md;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                ParentUiSpacing.md,
                horizontalPadding,
                ParentUiSpacing.xl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TrackingHeader(),
                      SizedBox(height: ParentUiSpacing.lg),
                      _LiveMapCard(),
                      SizedBox(height: ParentUiSpacing.lg),
                      _TripStatusCard(),
                      SizedBox(height: ParentUiSpacing.lg),
                      _SectionTitle(title: 'Route progress'),
                      SizedBox(height: ParentUiSpacing.sm),
                      RouteStopTile(
                        stopName: 'Kacyiru pickup point',
                        time: '07:10',
                        status: RouteStopStatus.completed,
                        position: 1,
                        isLast: false,
                      ),
                      RouteStopTile(
                        stopName: 'Kimironko main road',
                        time: '07:25',
                        status: RouteStopStatus.current,
                        position: 2,
                        isLast: false,
                      ),
                      RouteStopTile(
                        stopName: 'School gate',
                        time: '07:45',
                        status: RouteStopStatus.upcoming,
                        position: 3,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TrackingHeader extends StatelessWidget {
  const _TrackingHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: ParentUiColors.lightOrange,
            borderRadius: BorderRadius.circular(ParentUiRadius.md),
            border: Border.all(color: ParentUiColors.border),
          ),
          child: const Icon(
            Icons.map_outlined,
            color: ParentUiColors.orange,
            size: 28,
          ),
        ),
        const SizedBox(width: ParentUiSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Tracking', style: ParentUiTextStyles.title),
              const SizedBox(height: 4),
              Text(
                'Bus KGL 204 is moving toward school',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ParentUiTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveMapCard extends StatelessWidget {
  const _LiveMapCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7C2),
        borderRadius: BorderRadius.circular(ParentUiRadius.xl),
        border: Border.all(color: ParentUiColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _MockMapGrid()),
          const Positioned(
            left: 30,
            top: 70,
            child: _MapMarker(
              icon: Icons.home_rounded,
              label: 'Home',
              color: ParentUiColors.blue,
            ),
          ),
          const Positioned(right: 34, top: 130, child: _BusMarker()),
          const Positioned(
            left: 60,
            bottom: 60,
            child: _MapMarker(
              icon: Icons.school_rounded,
              label: 'School',
              color: ParentUiColors.success,
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.all(ParentUiSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ParentUiRadius.lg),
              ),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: const BoxDecoration(
                      color: ParentUiColors.lightOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      color: ParentUiColors.orange,
                    ),
                  ),
                  const SizedBox(width: ParentUiSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bus is 2 stops away',
                          style: ParentUiTextStyles.body.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Estimated arrival: 12 minutes',
                          style: ParentUiTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.near_me_rounded,
                    color: ParentUiColors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockMapGrid extends StatelessWidget {
  const _MockMapGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MockMapPainter());
  }
}

class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final thinRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = ParentUiColors.orange
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.22),
      Offset(size.width * 0.88, size.height * 0.18),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.16, size.height * 0.50),
      Offset(size.width * 0.94, size.height * 0.45),
      thinRoadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.78),
      Offset(size.width * 0.75, size.height * 0.70),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.10),
      Offset(size.width * 0.18, size.height * 0.86),
      thinRoadPaint,
    );

    final routePath = Path()
      ..moveTo(size.width * 0.18, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.22,
        size.width * 0.68,
        size.height * 0.43,
      )
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.58,
        size.width * 0.30,
        size.height * 0.78,
      );

    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _BusMarker extends StatelessWidget {
  const _BusMarker();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.90, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Column(
        children: [
          Container(
            height: 66,
            width: 66,
            decoration: BoxDecoration(
              color: ParentUiColors.orange,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.16),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_bus_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: ParentUiSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ParentUiSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'Bus KGL 204',
              style: ParentUiTextStyles.caption.copyWith(
                color: ParentUiColors.darkOrange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: ParentUiSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ParentUiSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            style: ParentUiTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _TripStatusCard extends StatelessWidget {
  const _TripStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: parentCardDecoration(),
      padding: const EdgeInsets.all(ParentUiSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 420;

          final children = [
            const _TripMetric(
              icon: Icons.schedule_outlined,
              label: 'ETA',
              value: '12 min',
            ),
            const _TripMetric(
              icon: Icons.route_outlined,
              label: 'Distance',
              value: '3.2 km',
            ),
            const _TripMetric(
              icon: Icons.speed_outlined,
              label: 'Status',
              value: 'On time',
            ),
          ];

          if (isSmall) {
            return Column(
              children: children
                  .map(
                    (child) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: ParentUiSpacing.sm,
                      ),
                      child: child,
                    ),
                  )
                  .toList(),
            );
          }

          return Row(
            children: [
              Expanded(child: children[0]),
              const SizedBox(width: ParentUiSpacing.sm),
              Expanded(child: children[1]),
              const SizedBox(width: ParentUiSpacing.sm),
              Expanded(child: children[2]),
            ],
          );
        },
      ),
    );
  }
}

class _TripMetric extends StatelessWidget {
  const _TripMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ParentUiSpacing.sm),
      decoration: BoxDecoration(
        color: ParentUiColors.lightOrange,
        borderRadius: BorderRadius.circular(ParentUiRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: ParentUiColors.orange, size: 22),
          const SizedBox(width: ParentUiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: ParentUiTextStyles.caption),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ParentUiTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: ParentUiTextStyles.heading);
  }
}
