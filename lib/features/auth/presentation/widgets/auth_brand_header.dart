import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

class AuthBrandHeader extends StatefulWidget {
  const AuthBrandHeader({super.key, required this.subtitle});

  final String subtitle;

  @override
  State<AuthBrandHeader> createState() => _AuthBrandHeaderState();
}

class _AuthBrandHeaderState extends State<AuthBrandHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _busFloat;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _busFloat = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          children: [
            // Animated bus logo
            ScaleTransition(
              scale: _busFloat,
              child: Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ParentUiColors.orange, ParentUiColors.darkOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(ParentUiRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: ParentUiColors.orange.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: ParentUiSpacing.md),
            // App name
            Text(
              'SafeRide',
              style: ParentUiTextStyles.title.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: ParentUiSpacing.xs),
            // Subtitle
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: ParentUiTextStyles.caption.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
