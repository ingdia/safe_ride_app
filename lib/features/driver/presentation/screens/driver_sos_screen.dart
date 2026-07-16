import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/parent/presentation/widgets/parent_ui_constants.dart';
import '../../domain/entities/emergency_alert.dart';
import '../providers/sos_provider.dart';
import '../widgets/sos_button.dart';

class DriverSosScreen extends ConsumerStatefulWidget {
  const DriverSosScreen({super.key});

  @override
  ConsumerState<DriverSosScreen> createState() => _DriverSosScreenState();
}

class _DriverSosScreenState extends ConsumerState<DriverSosScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _feedbackController;
  late final Animation<double> _feedbackFade;
  late final Animation<Offset> _feedbackSlide;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _feedbackFade = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.easeOut,
    );
    _feedbackSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _showConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SosConfirmationDialog(),
    );

    if (!mounted) return;

    if (confirmed == true) {
      ref.read(sosProvider.notifier).triggerSos(
            driverName: 'Bob Driver',
            vehicle: 'KGL 204 B',
            emergencyType: EmergencyType.other,
          );
    } else {
      ref.read(sosProvider.notifier).cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SosState>(sosProvider, (_, next) {
      if (next is SosSuccess || next is SosCancelled) {
        _feedbackController
          ..reset()
          ..forward();
      }
      if (next is SosError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text((next).message),
            backgroundColor: ParentUiColors.danger,
          ),
        );
      }
    });

    final sosState = ref.watch(sosProvider);

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ParentUiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SosHeader(sosState: sosState),
              const Spacer(),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: switch (sosState) {
                    SosSuccess() => _FeedbackCard(
                        key: const ValueKey('success'),
                        fade: _feedbackFade,
                        slide: _feedbackSlide,
                        isSuccess: true,
                        onReset: () => ref.read(sosProvider.notifier).reset(),
                      ),
                    SosCancelled() => _FeedbackCard(
                        key: const ValueKey('cancelled'),
                        fade: _feedbackFade,
                        slide: _feedbackSlide,
                        isSuccess: false,
                        onReset: () => ref.read(sosProvider.notifier).reset(),
                      ),
                    _ => SosButton(
                        key: const ValueKey('button'),
                        onPressed: _showConfirmationDialog,
                        isLoading: sosState is SosLoading,
                      ),
                  },
                ),
              ),
              const Spacer(),
              _SosInfoRow(sosState: sosState),
              const SizedBox(height: ParentUiSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _SosHeader extends StatelessWidget {
  const _SosHeader({required this.sosState});
  final SosState sosState;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: ParentUiColors.danger.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(ParentUiRadius.md),
            border: Border.all(
              color: ParentUiColors.danger.withValues(alpha: 0.3),
            ),
          ),
          child: const Icon(
            Icons.emergency_rounded,
            color: ParentUiColors.danger,
            size: 28,
          ),
        ),
        const SizedBox(width: ParentUiSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emergency SOS', style: ParentUiTextStyles.title),
            const SizedBox(height: 2),
            Text(
              sosState is SosSuccess
                  ? 'Alert sent — help is on the way'
                  : 'Press only in a real emergency',
              style: ParentUiTextStyles.caption,
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Feedback card — success or cancelled
// ---------------------------------------------------------------------------

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    super.key,
    required this.fade,
    required this.slide,
    required this.isSuccess,
    required this.onReset,
  });

  final Animation<double> fade;
  final Animation<Offset> slide;
  final bool isSuccess;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? ParentUiColors.danger : ParentUiColors.textGrey;
    final bgColor = isSuccess
        ? ParentUiColors.danger.withValues(alpha: 0.08)
        : Colors.grey.withValues(alpha: 0.08);
    final icon = isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final title = isSuccess ? 'SOS Alert Sent!' : 'SOS Cancelled';
    final subtitle = isSuccess
        ? 'Emergency services and school admin have been notified.\nStay calm — help is on the way.'
        : 'No alert was sent.\nPress SOS again if you need help.';

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ParentUiSpacing.lg),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(ParentUiRadius.lg),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 64),
              const SizedBox(height: ParentUiSpacing.md),
              Text(
                title,
                style: ParentUiTextStyles.heading.copyWith(color: color),
              ),
              const SizedBox(height: ParentUiSpacing.sm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: ParentUiTextStyles.body.copyWith(
                  color: ParentUiColors.textGrey,
                ),
              ),
              const SizedBox(height: ParentUiSpacing.lg),
              GestureDetector(
                onTap: onReset,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ParentUiSpacing.lg,
                    vertical: ParentUiSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(ParentUiRadius.sm),
                    border: Border.all(color: ParentUiColors.border),
                  ),
                  child: Text(
                    'Back to SOS',
                    style: ParentUiTextStyles.body.copyWith(
                      color: ParentUiColors.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row at the bottom
// ---------------------------------------------------------------------------

class _SosInfoRow extends StatelessWidget {
  const _SosInfoRow({required this.sosState});
  final SosState sosState;

  @override
  Widget build(BuildContext context) {
    if (sosState is SosSuccess) {
      return _InfoChip(
        icon: Icons.access_time_rounded,
        label: 'Alert sent at ${_formattedNow()}',
        color: ParentUiColors.danger,
      );
    }
    return const Row(
      children: [
        Expanded(
          child: _InfoChip(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Notifies admin',
            color: ParentUiColors.orange,
          ),
        ),
        SizedBox(width: ParentUiSpacing.sm),
        Expanded(
          child: _InfoChip(
            icon: Icons.family_restroom_rounded,
            label: 'Notifies parents',
            color: ParentUiColors.orange,
          ),
        ),
      ],
    );
  }

  String _formattedNow() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ParentUiSpacing.md,
        vertical: ParentUiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ParentUiRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: ParentUiSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: ParentUiTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Confirmation dialog
// ---------------------------------------------------------------------------

class _SosConfirmationDialog extends StatelessWidget {
  const _SosConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ParentUiRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ParentUiSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: ParentUiColors.danger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: ParentUiColors.danger,
                size: 36,
              ),
            ),
            const SizedBox(height: ParentUiSpacing.md),
            Text(
              'Send SOS Alert?',
              style: ParentUiTextStyles.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ParentUiSpacing.sm),
            Text(
              'This will immediately notify school admin and all parents on this route. Only use in a real emergency.',
              style: ParentUiTextStyles.body.copyWith(
                color: ParentUiColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ParentUiSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(ParentUiRadius.sm),
                        border: Border.all(color: ParentUiColors.border),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: ParentUiTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ParentUiSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: ParentUiColors.danger,
                        borderRadius: BorderRadius.circular(ParentUiRadius.sm),
                        boxShadow: [
                          BoxShadow(
                            color: ParentUiColors.danger.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Send SOS',
                          style: ParentUiTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
