import 'package:flutter/material.dart';

import '../widgets/parent_ui_constants.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: ParentUiSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ProfileHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ParentUiSpacing.lg,
                      0,
                      ParentUiSpacing.lg,
                      ParentUiSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -28),
                          child: const _ProfileCard(),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Text(
                            'Settings',
                            style: ParentUiTextStyles.heading.copyWith(
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: ParentUiSpacing.sm),
                        const _SettingsTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          subtitle: 'Manage alert preferences',
                        ),
                        const SizedBox(height: ParentUiSpacing.sm),
                        const _SettingsTile(
                          icon: Icons.shield_outlined,
                          title: 'Privacy & Security',
                          subtitle: 'Update your security settings',
                        ),
                        const SizedBox(height: ParentUiSpacing.sm),
                        const _SettingsTile(
                          icon: Icons.settings_outlined,
                          title: 'App Settings',
                          subtitle: 'Customize your experience',
                        ),
                        const SizedBox(height: ParentUiSpacing.sm),
                        const _SettingsTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          subtitle: 'Get help and contact us',
                        ),
                        const SizedBox(height: ParentUiSpacing.xl),
                        const _LogoutButton(),
                        const SizedBox(height: ParentUiSpacing.xl),
                        Center(
                          child: Text(
                            'SafeRide v1.0.0',
                            style: ParentUiTextStyles.caption.copyWith(
                              color: ParentUiColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        ParentUiSpacing.lg,
        ParentUiSpacing.xl,
        ParentUiSpacing.lg,
        ParentUiSpacing.lg,
      ),
      color: ParentUiColors.orange,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Manage your account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ParentUiColors.orange, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(ParentUiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _ParentAvatar(),
              SizedBox(width: ParentUiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uwimana Claudine',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Parent',
                      style: TextStyle(
                        color: ParentUiColors.darkOrange,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ParentUiSpacing.lg),
          const Divider(color: ParentUiColors.border),
          const SizedBox(height: ParentUiSpacing.md),
          const _ContactRow(
            icon: Icons.mail_outline_rounded,
            text: 'claudine.uwimana@email.com',
          ),
          const SizedBox(height: ParentUiSpacing.sm),
          const _ContactRow(
            icon: Icons.call_outlined,
            text: '+250 788 123 456',
          ),
          const SizedBox(height: ParentUiSpacing.sm),
          const _ContactRow(
            icon: Icons.location_on_outlined,
            text: 'Kacyiru, Kigali',
          ),
          const SizedBox(height: ParentUiSpacing.lg),
          const Divider(color: ParentUiColors.border),
          const SizedBox(height: ParentUiSpacing.md),
          Text(
            'Children',
            style: ParentUiTextStyles.body.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: ParentUiSpacing.md),
          const _ChildProfileTile(
            initials: 'IU',
            name: 'Ineza Uwase - Primary 4',
          ),
          const SizedBox(height: ParentUiSpacing.sm),
          const _ChildProfileTile(
            initials: 'GN',
            name: 'Ganza Ntwali - Primary 1',
          ),
        ],
      ),
    );
  }
}

class _ParentAvatar extends StatelessWidget {
  const _ParentAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      width: 86,
      decoration: BoxDecoration(
        color: ParentUiColors.lightOrange,
        shape: BoxShape.circle,
        border: Border.all(color: ParentUiColors.orange, width: 4),
      ),
      child: const Center(
        child: Text(
          'UC',
          style: TextStyle(
            color: ParentUiColors.darkOrange,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ParentUiColors.orange, size: 24),
        const SizedBox(width: ParentUiSpacing.md),
        Expanded(
          child: Text(
            text,
            style: ParentUiTextStyles.body.copyWith(
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChildProfileTile extends StatelessWidget {
  const _ChildProfileTile({required this.initials, required this.name});

  final String initials;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ParentUiSpacing.md),
      decoration: BoxDecoration(
        color: ParentUiColors.lightOrange,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ParentUiColors.orange, width: 2),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: ParentUiColors.darkOrange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: ParentUiSpacing.md),
          Expanded(
            child: Text(
              name,
              style: ParentUiTextStyles.body.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ParentUiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ParentUiColors.orange),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: ParentUiColors.lightOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ParentUiColors.orange),
          ),
          const SizedBox(width: ParentUiSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ParentUiTextStyles.heading.copyWith(fontSize: 19),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: ParentUiTextStyles.caption.copyWith(
                    color: ParentUiColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: ParentUiColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Logout & Switch Role'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 2),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}
