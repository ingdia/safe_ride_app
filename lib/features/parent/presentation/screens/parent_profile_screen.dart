import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_child_entity.dart';
import '../providers/parent_children_provider.dart';
import '../widgets/parent_ui_constants.dart';

class ParentProfileScreen extends ConsumerWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(parentChildrenProvider);

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
                          child: _ProfileCard(children: children),
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
                        _SettingsTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          subtitle: 'Manage alert preferences',
                          onTap: () {
                            _showNotificationSettingsDialog(context);
                          },
                        ),
                        const SizedBox(height: ParentUiSpacing.sm),
                        _SettingsTile(
                          icon: Icons.shield_outlined,
                          title: 'Privacy & Security',
                          subtitle: 'Update your security settings',
                          onTap: () {
                            _showInfoDialog(
                              context,
                              icon: Icons.shield_outlined,
                              title: 'Privacy & Security',
                              message:
                                  'Your SafeRide account is protected. You can review trusted devices, update your password, and manage privacy settings from here.',
                            );
                          },
                        ),
                        const SizedBox(height: ParentUiSpacing.sm),
                        _SettingsTile(
                          icon: Icons.settings_outlined,
                          title: 'App Settings',
                          subtitle: 'Customize your experience',
                          onTap: () {
                            _showAppSettingsDialog(context);
                          },
                        ),
                        const SizedBox(height: ParentUiSpacing.sm),
                        _SettingsTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          subtitle: 'Get help and contact us',
                          onTap: () {
                            _showInfoDialog(
                              context,
                              icon: Icons.help_outline_rounded,
                              title: 'Help & Support',
                              message:
                                  'For support, contact SafeRide support at support@saferide.rw or call +250 788 000 111.',
                            );
                          },
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
            'Manage your account and children',
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

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({required this.children});

  final List<ParentChildEntity> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Children',
                  style: ParentUiTextStyles.body.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      return const _ChildFormDialog();
                    },
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Child'),
                style: TextButton.styleFrom(
                  foregroundColor: ParentUiColors.orange,
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: ParentUiSpacing.md),
          if (children.isEmpty)
            const _EmptyChildrenCard()
          else
            ...children.map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: ParentUiSpacing.sm),
                child: _ChildProfileTile(child: child),
              ),
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

class _ChildProfileTile extends ConsumerWidget {
  const _ChildProfileTile({required this.child});

  final ParentChildEntity child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(ParentUiSpacing.md),
      decoration: BoxDecoration(
        color: ParentUiColors.lightOrange,
        borderRadius: BorderRadius.circular(18),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 460;

          final childInfo = Row(
            children: [
              _ChildAvatar(name: child.fullName),
              const SizedBox(width: ParentUiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.fullName,
                      style: ParentUiTextStyles.body.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${child.grade} • ${child.busNumber} • ${child.pickupStop}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ParentUiTextStyles.caption.copyWith(
                        color: ParentUiColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actionButtons = Wrap(
            spacing: ParentUiSpacing.xs,
            runSpacing: ParentUiSpacing.xs,
            children: [
              _SmallChildActionButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      return _ChildFormDialog(child: child);
                    },
                  );
                },
              ),
              _SmallChildActionButton(
                icon: Icons.delete_outline_rounded,
                label: 'Remove',
                isDanger: true,
                onPressed: () {
                  _showRemoveChildDialog(context, ref, child);
                },
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                childInfo,
                const SizedBox(height: ParentUiSpacing.sm),
                actionButtons,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: childInfo),
              const SizedBox(width: ParentUiSpacing.sm),
              actionButtons,
            ],
          );
        },
      ),
    );
  }

  void _showRemoveChildDialog(
    BuildContext context,
    WidgetRef ref,
    ParentChildEntity child,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove child?'),
          content: Text(
            'Are you sure you want to remove ${child.fullName} from your children list?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(parentChildrenProvider.notifier).removeChild(child.id);
                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${child.fullName} removed')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}

class _ChildAvatar extends StatelessWidget {
  const _ChildAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
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
    );
  }
}

class _SmallChildActionButton extends StatelessWidget {
  const _SmallChildActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Colors.red : ParentUiColors.orange;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(
          horizontal: ParentUiSpacing.sm,
          vertical: ParentUiSpacing.xs,
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ChildFormDialog extends ConsumerStatefulWidget {
  const _ChildFormDialog({this.child});

  final ParentChildEntity? child;

  @override
  ConsumerState<_ChildFormDialog> createState() => _ChildFormDialogState();
}

class _ChildFormDialogState extends ConsumerState<_ChildFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _gradeController;
  late final TextEditingController _busNumberController;
  late final TextEditingController _pickupStopController;

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController(
      text: widget.child?.fullName ?? '',
    );
    _gradeController = TextEditingController(text: widget.child?.grade ?? '');
    _busNumberController = TextEditingController(
      text: widget.child?.busNumber ?? 'Bus #12',
    );
    _pickupStopController = TextEditingController(
      text: widget.child?.pickupStop ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _gradeController.dispose();
    _busNumberController.dispose();
    _pickupStopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.child != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit child' : 'Add child'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ChildTextField(
                  controller: _fullNameController,
                  label: 'Full name',
                  hintText: 'Example: Ineza Uwase',
                ),
                const SizedBox(height: ParentUiSpacing.sm),
                _ChildTextField(
                  controller: _gradeController,
                  label: 'Grade',
                  hintText: 'Example: Primary 4',
                ),
                const SizedBox(height: ParentUiSpacing.sm),
                _ChildTextField(
                  controller: _busNumberController,
                  label: 'Bus number',
                  hintText: 'Example: Bus #12',
                ),
                const SizedBox(height: ParentUiSpacing.sm),
                _ChildTextField(
                  controller: _pickupStopController,
                  label: 'Pickup stop',
                  hintText: 'Example: Kacyiru',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveChild,
          style: ElevatedButton.styleFrom(
            backgroundColor: ParentUiColors.orange,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Save changes' : 'Add child'),
        ),
      ],
    );
  }

  void _saveChild() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final controller = ref.read(parentChildrenProvider.notifier);
    final fullName = _fullNameController.text.trim();

    if (widget.child == null) {
      controller.addChild(
        fullName: fullName,
        grade: _gradeController.text.trim(),
        busNumber: _busNumberController.text.trim(),
        pickupStop: _pickupStopController.text.trim(),
      );
    } else {
      controller.updateChild(
        widget.child!.copyWith(
          fullName: fullName,
          grade: _gradeController.text.trim(),
          busNumber: _busNumberController.text.trim(),
          pickupStop: _pickupStopController.text.trim(),
        ),
      );
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.child == null ? '$fullName added' : '$fullName updated',
        ),
      ),
    );
  }
}

class _ChildTextField extends StatelessWidget {
  const _ChildTextField({
    required this.controller,
    required this.label,
    required this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        final trimmedValue = value?.trim() ?? '';

        if (trimmedValue.isEmpty) {
          return '$label is required';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _EmptyChildrenCard extends StatelessWidget {
  const _EmptyChildrenCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ParentUiSpacing.md),
      decoration: BoxDecoration(
        color: ParentUiColors.lightOrange,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'No children added yet. Tap Add Child to add one.',
        style: ParentUiTextStyles.body.copyWith(
          color: ParentUiColors.textSecondary,
        ),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(ParentUiSpacing.md),
          decoration: BoxDecoration(
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
        ),
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
        onPressed: () {
          _showLogoutDialog(context);
        },
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

void _showNotificationSettingsDialog(BuildContext context) {
  bool boardingAlerts = true;
  bool delayAlerts = true;
  bool arrivalAlerts = true;

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('Notification Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogSwitchTile(
                  title: 'Boarding alerts',
                  subtitle: 'Notify me when my child boards the bus',
                  value: boardingAlerts,
                  onChanged: (value) {
                    setState(() {
                      boardingAlerts = value;
                    });
                  },
                ),
                _DialogSwitchTile(
                  title: 'Delay alerts',
                  subtitle: 'Notify me when the bus is delayed',
                  value: delayAlerts,
                  onChanged: (value) {
                    setState(() {
                      delayAlerts = value;
                    });
                  },
                ),
                _DialogSwitchTile(
                  title: 'Arrival alerts',
                  subtitle: 'Notify me when my child arrives safely',
                  value: arrivalAlerts,
                  onChanged: (value) {
                    setState(() {
                      arrivalAlerts = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification preferences saved'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ParentUiColors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showAppSettingsDialog(BuildContext context) {
  bool darkMode = false;
  bool locationUpdates = true;

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('App Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogSwitchTile(
                  title: 'Dark mode',
                  subtitle: 'Use darker colors in the app',
                  value: darkMode,
                  onChanged: (value) {
                    setState(() {
                      darkMode = value;
                    });
                  },
                ),
                _DialogSwitchTile(
                  title: 'Live location updates',
                  subtitle: 'Refresh bus location automatically',
                  value: locationUpdates,
                  onChanged: (value) {
                    setState(() {
                      locationUpdates = value;
                    });
                  },
                ),
                const SizedBox(height: ParentUiSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(ParentUiSpacing.md),
                  decoration: BoxDecoration(
                    color: ParentUiColors.lightOrange,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Language: English',
                    style: ParentUiTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('App settings saved')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ParentUiColors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showInfoDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: ParentUiColors.orange),
            const SizedBox(width: ParentUiSpacing.sm),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ParentUiColors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
}

void _showLogoutDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Logout & Switch Role?'),
        content: const Text(
          'Are you sure you want to logout and switch to another role?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout action selected')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}

class _DialogSwitchTile extends StatelessWidget {
  const _DialogSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: ParentUiColors.orange,
      title: Text(
        title,
        style: ParentUiTextStyles.body.copyWith(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        subtitle,
        style: ParentUiTextStyles.caption.copyWith(
          color: ParentUiColors.textSecondary,
        ),
      ),
    );
  }
}
