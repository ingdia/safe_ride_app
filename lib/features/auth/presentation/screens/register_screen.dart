import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/auth_routes.dart';
import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authProvider.notifier).register(
          name: _nameController.text,
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

    final isLoading = ref.watch(authProvider) is AuthLoading;

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: ParentUiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ParentUiSpacing.xl),
              const _RegisterHeader(),
              const SizedBox(height: ParentUiSpacing.xl),
              _RegisterCard(
                formKey: _formKey,
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                onRegister: _onRegister,
                isLoading: isLoading,
              ),
              const SizedBox(height: ParentUiSpacing.lg),
              const _LoginRow(),
              const SizedBox(height: ParentUiSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

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
          'Create account',
          style: ParentUiTextStyles.title.copyWith(fontSize: 28),
        ),
        const SizedBox(height: ParentUiSpacing.xs),
        Text(
          'Join SafeRide and keep your child safe',
          style: ParentUiTextStyles.caption.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegister,
    required this.isLoading,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onRegister;
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
            Text('Sign up', style: ParentUiTextStyles.heading),
            const SizedBox(height: ParentUiSpacing.lg),
            AuthTextField(
              controller: nameController,
              hint: 'Full name',
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Full name is required';
                if (v.trim().length < 3) return 'Name must be at least 3 characters';
                return null;
              },
            ),
            const SizedBox(height: ParentUiSpacing.md),
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
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'Minimum 8 characters';
                return null;
              },
            ),
            const SizedBox(height: ParentUiSpacing.md),
            AuthTextField(
              controller: confirmPasswordController,
              hint: 'Confirm password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onRegister(),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != passwordController.text) return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: ParentUiSpacing.lg),
            AuthPrimaryButton(
              label: 'Create account',
              onPressed: onRegister,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginRow extends StatelessWidget {
  const _LoginRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
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
