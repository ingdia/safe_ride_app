import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../providers/buses_provider.dart';
import '../providers/users_provider.dart';
import '../widgets/admin_notification_bell.dart';
import '../widgets/admin_ui_constants.dart';
import '../widgets/gradient_header.dart';

class ManageDriversScreen extends ConsumerWidget {
  const ManageDriversScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drivers = ref.watch(driversProvider);

    return Scaffold(
      backgroundColor: AdminUiColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientHeader(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: HeaderTitleBlock(
                        title: 'Drivers',
                        subtitle: '${drivers.length} driver accounts',
                      ),
                    ),
                    const AdminNotificationBell(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AdminUiSpacing.md,
                AdminUiSpacing.md,
                AdminUiSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCreateDriverDialog(context, ref),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
                    label: const Text('Create Driver Account'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AdminUiSpacing.md),
              sliver: drivers.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('No drivers yet. Create one above.')),
                      ),
                    )
                  : SliverList.separated(
                      itemCount: drivers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AdminUiSpacing.sm),
                      itemBuilder: (context, index) => _DriverCard(driver: drivers[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDriverDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: _generateTempPassword());
    final formKey = GlobalKey<FormState>();
    bool submitting = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Create Driver Account'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Full name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: AdminUiSpacing.sm),
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                      ),
                      const SizedBox(height: AdminUiSpacing.sm),
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: AdminUiSpacing.sm),
                      TextFormField(
                        controller: passwordCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Temporary password',
                          helperText: 'Share this with the driver directly.',
                        ),
                        validator: (v) =>
                            (v == null || v.length < 6) ? 'At least 6 characters' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) return;
                          setState(() => submitting = true);
                          try {
                            await ref.read(driversProvider.notifier).createDriver(
                                  name: nameCtrl.text,
                                  email: emailCtrl.text,
                                  password: passwordCtrl.text,
                                  phone: phoneCtrl.text,
                                );
                            if (dialogContext.mounted) Navigator.pop(dialogContext);
                            if (context.mounted) {
                              showDialog<void>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Driver account created'),
                                  content: Text(
                                    'Email: ${emailCtrl.text}\n'
                                    'Temporary password: ${passwordCtrl.text}\n\n'
                                    'Share these with the driver. They can log in once '
                                    'assigned to a bus below.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Done'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } catch (e) {
                            setState(() => submitting = false);
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text('Failed to create driver: $e')),
                              );
                            }
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _generateTempPassword() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'Ride${now.toString().substring(7)}!';
  }
}

class _DriverCard extends ConsumerWidget {
  const _DriverCard({required this.driver});
  final UserModel driver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buses = ref.watch(busesProvider);
    final isAssigned = driver.busId != null && driver.busId!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AdminUiSpacing.md),
      decoration: BoxDecoration(
        color: AdminUiColors.cardBackground,
        borderRadius: BorderRadius.circular(AdminUiRadii.card),
        border: Border.all(color: AdminUiColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AdminUiColors.statCardBackground,
                child: Icon(Icons.person_rounded, color: AdminUiColors.primaryOrange),
              ),
              const SizedBox(width: AdminUiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(driver.email, style: const TextStyle(color: AdminUiColors.textSecondary, fontSize: 12.5)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAssigned ? AdminUiColors.onTimeBg : AdminUiColors.statCardBackground,
                  borderRadius: BorderRadius.circular(AdminUiRadii.chip),
                ),
                child: Text(
                  isAssigned ? 'Assigned' : 'Unassigned',
                  style: TextStyle(
                    color: isAssigned ? AdminUiColors.onTimeFg : AdminUiColors.primaryOrange,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminUiSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: buses.any((b) => b.busId == driver.busId) ? driver.busId : null,
            decoration: const InputDecoration(labelText: 'Assigned bus'),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('Unassigned')),
              for (final bus in buses)
                DropdownMenuItem(value: bus.busId, child: Text('Bus ${bus.plateNumber}')),
            ],
            onChanged: (busId) {
              ref.read(driversProvider.notifier).assignBus(driverUid: driver.userId, busId: busId);
            },
          ),
        ],
      ),
    );
  }
}
