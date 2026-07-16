import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).forgotPassword(
          email: _emailController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, state) {
      if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: ParentUiColors.danger,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    final isSuccess = authState is AuthPasswordResetSent;

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: ParentUiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ParentUiSpacing.xl),
              const _ForgotPasswordHeader(),
              const SizedBox(height: ParentUiSpacing.xl),
              isSuccess
                  ? const _SuccessCard()
                  : _ForgotPasswordCard(
                      formKey: _formKey,
                      emailController: _emailController,
                      onSubmit: _onSubmit,
                      isLoading: isLoading,
                    ),
              const SizedBox(height: ParentUiSpacing.lg),
              const _BackToLoginRow(),
              const SizedBox(height: ParentUiSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordHeader extends StatelessWidget {
  const _ForgotPasswordHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ParentUiColors.orange, ParentUiColors.darkOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ParentUiRadius.md),
            boxShadow: [
              BoxShadow(
                color: ParentUiColors.orange.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_bus_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: ParentUiSpacing.lg),
        Text(
          'Reset password',
          style: ParentUiTextStyles.title.copyWith(fontSize: 28),
        ),
        const SizedBox(height: ParentUiSpacing.xs),
        Text(
          'We will send a reset link to your email',
          style: ParentUiTextStyles.caption.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}

class _ForgotPasswordCard extends StatelessWidget {
  const _ForgotPasswordCard({
    required this.formKey,
    required this.emailController,
    required this.onSubmit,
    required this.isLoading,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: parentCardDecoration(),
      padding: const EdgeInsets.all(ParentUiSpacing.lg),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forgot password?', style: ParentUiTextStyles.heading),
            const SizedBox(height: ParentUiSpacing.xs),
            Text(
              'Enter the email address linked to your account.',
              style: ParentUiTextStyles.caption.copyWith(height: 1.4),
            ),
            const SizedBox(height: ParentUiSpacing.lg),
            AuthTextField(
              controller: emailController,
              hint: 'Email address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSubmit(),
              validator: AppValidators.email,
            ),
            const SizedBox(height: ParentUiSpacing.lg),
            AuthPrimaryButton(
              label: 'Send reset link',
              onPressed: onSubmit,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: parentCardDecoration(),
      padding: const EdgeInsets.all(ParentUiSpacing.lg),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: ParentUiColors.success,
              size: 32,
            ),
          ),
          const SizedBox(height: ParentUiSpacing.md),
          Text('Check your inbox', style: ParentUiTextStyles.heading),
          const SizedBox(height: ParentUiSpacing.sm),
          Text(
            'A password reset link has been sent to your email address.',
            textAlign: TextAlign.center,
            style: ParentUiTextStyles.caption.copyWith(height: 1.5),
          ),
          const SizedBox(height: ParentUiSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: ParentUiSpacing.sm,
              horizontal: ParentUiSpacing.md,
            ),
            decoration: BoxDecoration(
              color: ParentUiColors.lightOrange,
              borderRadius: BorderRadius.circular(ParentUiRadius.sm),
              border: Border.all(color: ParentUiColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: ParentUiColors.orange,
                  size: 16,
                ),
                const SizedBox(width: ParentUiSpacing.xs),
                Text(
                  'Check your spam folder if not received',
                  style: ParentUiTextStyles.caption.copyWith(
                    color: ParentUiColors.darkOrange,
                    fontWeight: FontWeight.w600,
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

class _BackToLoginRow extends StatelessWidget {
  const _BackToLoginRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password? ',
          style: ParentUiTextStyles.caption.copyWith(fontSize: 13),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Sign in',
            style: ParentUiTextStyles.caption.copyWith(
              color: ParentUiColors.orange,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
