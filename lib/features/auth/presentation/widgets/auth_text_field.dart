import 'package:flutter/material.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      style: ParentUiTextStyles.body,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: ParentUiTextStyles.body.copyWith(
          color: ParentUiColors.textGrey,
        ),
        prefixIcon: Icon(
          widget.prefixIcon,
          color: ParentUiColors.textGrey,
          size: 20,
        ),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: ParentUiColors.textGrey,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ParentUiSpacing.md,
          vertical: ParentUiSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ParentUiRadius.md),
          borderSide: const BorderSide(color: ParentUiColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ParentUiRadius.md),
          borderSide: const BorderSide(color: ParentUiColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ParentUiRadius.md),
          borderSide: const BorderSide(color: ParentUiColors.orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ParentUiRadius.md),
          borderSide: const BorderSide(color: ParentUiColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ParentUiRadius.md),
          borderSide: const BorderSide(color: ParentUiColors.danger, width: 1.5),
        ),
      ),
    );
  }
}
