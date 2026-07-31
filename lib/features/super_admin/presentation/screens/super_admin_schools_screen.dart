import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/auth_routes.dart';
import '../../../admin/data/models/school_model.dart';
import '../../../admin/presentation/widgets/admin_ui_constants.dart';
import '../../../admin/presentation/widgets/gradient_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/super_admin_providers.dart';

class SuperAdminSchoolsScreen extends ConsumerWidget {
  const SuperAdminSchoolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolsAsync = ref.watch(allSchoolsProvider);

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
                    const Expanded(
                      child: HeaderTitleBlock(
                        title: 'Schools',
                        subtitle: 'Super admin — manage every school on SafeRide',
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AuthRoutes.login,
                            (_) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    ),
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
                    onPressed: () => _showCreateSchoolDialog(context, ref),
                    icon: const Icon(Icons.add_business_outlined, size: 20),
                    label: const Text('Add School'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                  ),
                ),
              ),
            ),
            schoolsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stackTrace) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Unable to load schools.\n$error', textAlign: TextAlign.center),
                ),
              ),
              data: (schools) {
                if (schools.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No schools yet. Add one above.')),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(AdminUiSpacing.md),
                  sliver: SliverList.separated(
                    itemCount: schools.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AdminUiSpacing.sm),
                    itemBuilder: (context, index) => _SchoolCard(school: schools[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSchoolDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add School'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'School name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AdminUiSpacing.sm),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
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
                if (!(formKey.currentState?.validate() ?? false)) return;
                await ref.read(superAdminRepositoryProvider).createSchool(
                      name: nameCtrl.text,
                      address: addressCtrl.text,
                    );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class _SchoolCard extends ConsumerWidget {
  const _SchoolCard({required this.school});
  final SchoolModel school;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsAsync = ref.watch(schoolAdminsProvider(school.schoolId));

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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AdminUiColors.statCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded, color: AdminUiColors.primaryOrange),
              ),
              const SizedBox(width: AdminUiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(school.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(school.address, style: const TextStyle(color: AdminUiColors.textSecondary, fontSize: 12.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminUiSpacing.sm),
          const Divider(height: 1, color: AdminUiColors.divider),
          const SizedBox(height: AdminUiSpacing.sm),
          Text('Admins', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AdminUiColors.textSecondary)),
          const SizedBox(height: 6),
          adminsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, st) => const Text('Unable to load admins.'),
            data: (admins) {
              if (admins.isEmpty) {
                return const Text('No admin yet for this school.', style: TextStyle(fontSize: 12.5));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final admin in admins)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text('${admin.name} • ${admin.email}', style: const TextStyle(fontSize: 12.5)),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AdminUiSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCreateAdminDialog(context, ref, school),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Add Admin'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateAdminDialog(BuildContext context, WidgetRef ref, SchoolModel school) {
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
              title: Text('Add Admin for ${school.name}'),
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
                          helperText: 'Share this with the school admin directly.',
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
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
                            await ref.read(superAdminRepositoryProvider).createSchoolAdmin(
                                  schoolId: school.schoolId,
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
                                  title: const Text('Admin account created'),
                                  content: Text(
                                    'Email: ${emailCtrl.text}\n'
                                    'Temporary password: ${passwordCtrl.text}\n\n'
                                    'Share these with the school admin.',
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
                                SnackBar(content: Text('Failed to create admin: $e')),
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
    return 'School${now.toString().substring(7)}!';
  }
}
