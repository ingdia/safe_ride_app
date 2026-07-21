import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ParentUiColors.orange, ParentUiColors.darkOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ParentUiRadius.md),
        boxShadow: [
          BoxShadow(
            color: ParentUiColors.orange.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(ParentUiRadius.md),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    label,
                    style: ParentUiTextStyles.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
