import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

/// Pulsing SOS button — pure UI, state driven from outside.
class SosButton extends StatefulWidget {
  const SosButton({
    super.key,
    required this.onPressed,
    this.isActive = false,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isActive;
  final bool isLoading;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onPressed,
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, child) => Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ParentUiColors.danger.withValues(
                      alpha: _opacity.value,
                    ),
                  ),
                ),
              ),
            ),
            // Middle ring
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ParentUiColors.danger.withValues(alpha: 0.15),
                border: Border.all(
                  color: ParentUiColors.danger.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
            // Core button
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFF3B3B), ParentUiColors.danger],
                  center: Alignment(-0.3, -0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ParentUiColors.danger.withValues(alpha: 0.5),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: widget.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SOS',
                          style: ParentUiTextStyles.title.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
