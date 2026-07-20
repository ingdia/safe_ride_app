import 'package:flutter/material.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    (
      'How do I track my bus in real-time?',
      'Go to the Map tab to see live GPS tracking of your bus location.',
    ),
    (
      'What should I do if the bus is delayed?',
      'Check the Alerts tab for delay notifications and estimated arrival times.',
    ),
    (
      'How do I update my contact information?',
      'Visit your Profile and contact support to update your details.',
    ),
    (
      'Can I receive notifications for multiple children?',
      'Yes, you can link multiple students to your parent account.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                child: HeaderTitleBlock(
                  title: 'Help & Support',
                  subtitle: "We're here to help you",
                  backLabel: 'Back to Profile',
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    'Contact Us',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AdminUiSpacing.sm),
                  _ContactTile(
                    icon: Icons.call_outlined,
                    title: 'Call Support',
                    subtitle: '1-800-BUS-HELP',
                    onTap: () {},
                  ),
                  const SizedBox(height: AdminUiSpacing.sm),
                  _ContactTile(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email Us',
                    subtitle: 'support@schoolbus.com',
                    onTap: () {},
                  ),
                  const SizedBox(height: AdminUiSpacing.sm),
                  _ContactTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Live Chat',
                    subtitle: 'Available 24/7',
                    onTap: () {},
                  ),
                  const SizedBox(height: AdminUiSpacing.lg),
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AdminUiSpacing.sm),
                  for (final faq in _faqs) ...[
                    _FaqTile(question: faq.$1, answer: faq.$2),
                    const SizedBox(height: AdminUiSpacing.sm),
                  ],
                  const SizedBox(height: AdminUiSpacing.sm),
                  _EmergencyBanner(onCall: () {}),
                  const SizedBox(height: AdminUiSpacing.lg),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdminUiRadii.card),
      hoverColor: AdminUiColors.primaryOrange.withValues(alpha: 0.04),
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(AdminUiSpacing.md),
        decoration: BoxDecoration(
          color: AdminUiColors.cardBackground,
          borderRadius: BorderRadius.circular(AdminUiRadii.card),
          border: Border.all(color: AdminUiColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AdminUiColors.statCardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AdminUiColors.primaryOrange, size: 18),
            ),
            const SizedBox(width: AdminUiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AdminUiColors.primaryOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        mouseCursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.all(AdminUiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.help_outline_rounded,
                    color: AdminUiColors.primaryOrange,
                    size: 18,
                  ),
                  const SizedBox(width: AdminUiSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AdminUiColors.textSecondary,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: AdminUiSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    widget.answer,
                    style: const TextStyle(
                      color: AdminUiColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyBanner extends StatelessWidget {
  final VoidCallback onCall;

  const _EmergencyBanner({required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.statCardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Support',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'For urgent safety concerns, please call our 24/7 emergency hotline',
            style: TextStyle(color: AdminUiColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: AdminUiSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminUiColors.delayedFg,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AdminUiRadii.button),
                ),
              ),
              child: const Text('Call Emergency: 911'),
            ),
          ),
        ],
      ),
    );
  }
}
