import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/auth_routes.dart';
import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, state) {
      if (state is AuthAuthenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.dashboardForRole(state.user.role),
          (_) => false,
        );
      } else if (state is AuthError) {
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

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: ParentUiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ParentUiSpacing.xl),
              const _AuthHeader(),
              const SizedBox(height: ParentUiSpacing.xl),
              _LoginCard(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                onLogin: _onLogin,
                isLoading: isLoading,
              ),
              const SizedBox(height: ParentUiSpacing.lg),
              const _RegisterRow(),
              const SizedBox(height: ParentUiSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

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
          'Welcome back',
          style: ParentUiTextStyles.title.copyWith(fontSize: 28),
        ),
        const SizedBox(height: ParentUiSpacing.xs),
        Text(
          'Sign in to track your child safely',
          style: ParentUiTextStyles.caption.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.isLoading,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
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
            Text('Sign in', style: ParentUiTextStyles.heading),
            const SizedBox(height: ParentUiSpacing.lg),
            AuthTextField(
              controller: emailController,
              hint: 'Email address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: ParentUiSpacing.md),
            AuthTextField(
              controller: passwordController,
              hint: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onLogin(),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ),
            const SizedBox(height: ParentUiSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AuthRoutes.forgotPassword,
                ),
                child: Text(
                  'Forgot password?',
                  style: ParentUiTextStyles.caption.copyWith(
                    color: ParentUiColors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: ParentUiSpacing.lg),
            AuthPrimaryButton(
              label: 'Sign in',
              onPressed: onLogin,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterRow extends StatelessWidget {
  const _RegisterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: ParentUiTextStyles.caption.copyWith(fontSize: 13),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AuthRoutes.register),
          child: Text(
            'Sign up',
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
