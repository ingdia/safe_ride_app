import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_child_entity.dart';
import '../../domain/entities/parent_profile_entity.dart';
import '../providers/parent_data_providers.dart';
import '../providers/parent_profile_actions_provider.dart';
import '../providers/parent_children_actions_provider.dart';
import '../widgets/parent_ui_constants.dart';

class ParentProfileScreen extends ConsumerWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(parentProfileStreamProvider);
    final childrenState = ref.watch(parentChildrenStreamProvider);

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: profileState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              _ProfileErrorState(message: error.toString()),
          data: (profile) {
            return _ProfileContent(
              profile: profile,
              childrenState: childrenState,
            );
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.profile, required this.childrenState});

  final ParentProfileEntity profile;
  final AsyncValue<List<ParentChildEntity>> childrenState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          _ProfileHeader(profile: profile),
          const SizedBox(height: 18),
          _ParentInfoCard(profile: profile),
          const SizedBox(height: 18),
          _ChildrenCard(childrenState: childrenState),
          const SizedBox(height: 18),
          _SettingsCard(profile: profile),
          const SizedBox(height: 18),
          _LogoutButton(profile: profile),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.profile});

  final ParentProfileEntity profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: ParentUiColors.orange,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showEditProfileDialog(context, ref, profile);
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ParentInfoCard extends StatelessWidget {
  const _ParentInfoCard({required this.profile});

  final ParentProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Parent Information'),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.person_outline,
            title: 'Full name',
            value: profile.fullName,
          ),
          _InfoRow(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: profile.phoneNumber,
          ),
          _InfoRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: profile.email,
          ),
          _InfoRow(
            icon: Icons.home_outlined,
            title: 'Address',
            value: profile.homeAddress,
          ),
          _InfoRow(
            icon: Icons.language_outlined,
            title: 'Language',
            value: profile.preferredLanguage,
          ),
        ],
      ),
    );
  }
}

class _ChildrenCard extends ConsumerWidget {
  const _ChildrenCard({required this.childrenState});

  final AsyncValue<List<ParentChildEntity>> childrenState;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle(title: 'Children')),
              IconButton(
                onPressed: () {
                  _showChildDialog(context, ref);
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: ParentUiColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          childrenState.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            ),
            error: (error, stackTrace) => Text(
              'Unable to load children.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
            data: (children) {
              if (children.isEmpty) {
                return const Text(
                  'No child added yet.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                );
              }

              return Column(
                children: [
                  for (final child in children) _ChildTile(child: child),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChildTile extends ConsumerWidget {
  const _ChildTile({required this.child});

  final ParentChildEntity child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ParentUiColors.orange.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ParentUiColors.orange.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: ParentUiColors.orange.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: ParentUiColors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${child.grade} • ${child.busNumber} • ${child.pickupStop}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showChildDialog(context, ref, child: child);
              }

              if (value == 'remove') {
                _confirmRemoveChild(context, ref, child);
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'remove', child: Text('Remove')),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.profile});

  final ParentProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Settings'),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage alert preferences',
            onTap: () => _showNotificationsDialog(context),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            subtitle: 'Review account security',
            onTap: () => _showInfoDialog(
              context,
              title: 'Privacy & Security',
              message:
                  'Your parent account is protected. Keep your login details private.',
            ),
          ),
          _SettingsTile(
            icon: Icons.settings_outlined,
            title: 'App Settings',
            subtitle: 'Language: ${profile.preferredLanguage}',
            onTap: () => _showAppSettingsDialog(context),
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Contact SafeRide support',
            onTap: () => _showInfoDialog(
              context,
              title: 'Help & Support',
              message: 'Email: support@saferide.rw\nPhone: +250 788 000 111',
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: ParentUiColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: ParentUiColors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.profile});

  final ParentProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context, profile.fullName),
        icon: const Icon(Icons.logout),
        label: const Text('Logout & Switch Role'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ParentUiColors.orange, size: 21),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, required this.margin});

  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _DialogSwitchTile extends StatefulWidget {
  const _DialogSwitchTile({required this.title, required this.value});

  final String title;
  final bool value;

  @override
  State<_DialogSwitchTile> createState() => _DialogSwitchTileState();
}

class _DialogSwitchTileState extends State<_DialogSwitchTile> {
  late bool value = widget.value;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      activeThumbColor: ParentUiColors.orange,
      title: Text(widget.title),
      onChanged: (newValue) {
        setState(() {
          value = newValue;
        });
      },
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Unable to load profile.\n$message',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

Future<void> _showEditProfileDialog(
  BuildContext context,
  WidgetRef ref,
  ParentProfileEntity profile,
) async {
  final nameController = TextEditingController(text: profile.fullName);
  final phoneController = TextEditingController(text: profile.phoneNumber);
  final emailController = TextEditingController(text: profile.email);
  final addressController = TextEditingController(text: profile.homeAddress);
  final languageController = TextEditingController(
    text: profile.preferredLanguage,
  );

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ProfileTextField(controller: nameController, label: 'Full name'),
              _ProfileTextField(
                controller: phoneController,
                label: 'Phone number',
                keyboardType: TextInputType.phone,
              ),
              _ProfileTextField(
                controller: emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              _ProfileTextField(
                controller: addressController,
                label: 'Home address',
              ),
              _ProfileTextField(
                controller: languageController,
                label: 'Preferred language',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedProfile = profile.copyWith(
                fullName: nameController.text,
                phoneNumber: phoneController.text,
                email: emailController.text,
                homeAddress: addressController.text,
                preferredLanguage: languageController.text,
              );

              await ref
                  .read(parentProfileActionsProvider)
                  .updateProfile(updatedProfile);

              if (!dialogContext.mounted) return;

              Navigator.pop(dialogContext);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully.')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );

  nameController.dispose();
  phoneController.dispose();
  emailController.dispose();
  addressController.dispose();
  languageController.dispose();
}

Future<void> _showChildDialog(
  BuildContext context,
  WidgetRef ref, {
  ParentChildEntity? child,
}) async {
  final nameController = TextEditingController(text: child?.fullName ?? '');
  final gradeController = TextEditingController(text: child?.grade ?? '');
  final busController = TextEditingController(text: child?.busNumber ?? '');
  final stopController = TextEditingController(text: child?.pickupStop ?? '');

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final isEditing = child != null;

      return AlertDialog(
        title: Text(isEditing ? 'Edit Child' : 'Add Child'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ProfileTextField(controller: nameController, label: 'Full name'),
              _ProfileTextField(controller: gradeController, label: 'Grade'),
              _ProfileTextField(controller: busController, label: 'Bus number'),
              _ProfileTextField(
                controller: stopController,
                label: 'Pickup stop',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isEditing) {
                final updatedChild = child.copyWith(
                  fullName: nameController.text,
                  grade: gradeController.text,
                  busNumber: busController.text,
                  pickupStop: stopController.text,
                );

                await ref
                    .read(parentChildrenActionsProvider)
                    .updateChild(updatedChild);
              } else {
                await ref
                    .read(parentChildrenActionsProvider)
                    .addChild(
                      fullName: nameController.text,
                      grade: gradeController.text,
                      busNumber: busController.text,
                      pickupStop: stopController.text,
                    );
              }

              if (!dialogContext.mounted) return;

              Navigator.pop(dialogContext);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditing
                        ? 'Child updated successfully.'
                        : 'Child added successfully.',
                  ),
                ),
              );
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      );
    },
  );

  nameController.dispose();
  gradeController.dispose();
  busController.dispose();
  stopController.dispose();
}

Future<void> _confirmRemoveChild(
  BuildContext context,
  WidgetRef ref,
  ParentChildEntity child,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Remove Child'),
        content: Text('Remove ${child.fullName} from your children list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(parentChildrenActionsProvider)
                  .deleteChild(child.id);

              if (!dialogContext.mounted) return;

              Navigator.pop(dialogContext);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Child removed successfully.')),
              );
            },
            child: const Text('Remove'),
          ),
        ],
      );
    },
  );
}

void _showNotificationsDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Notification Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogSwitchTile(title: 'Boarding alerts', value: true),
            _DialogSwitchTile(title: 'Delay alerts', value: true),
            _DialogSwitchTile(title: 'Arrival alerts', value: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

void _showAppSettingsDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('App Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogSwitchTile(title: 'Dark mode', value: false),
            _DialogSwitchTile(title: 'Live location updates', value: true),
            ListTile(
              leading: Icon(Icons.language_outlined),
              title: Text('Language'),
              subtitle: Text('English'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

void _showInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

void _showLogoutDialog(BuildContext context, String parentName) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Logout'),
        content: Text('$parentName, do you want to logout and switch role?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout action selected.')),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}
