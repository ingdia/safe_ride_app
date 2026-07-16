import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      hoverColor: foreground.withValues(alpha: 0.15),
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: foreground),
      ),
    );
  }
}
