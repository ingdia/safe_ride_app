import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_collections.dart';
import '../../../../core/routing/parent_routes.dart';
import '../../../../shared/utils/initials.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/parent_ui_constants.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _onboardingProvider =
    NotifierProvider.autoDispose<_OnboardingNotifier, _OnboardingState>(
  _OnboardingNotifier.new,
);

class _OnboardingState {
  const _OnboardingState({
    this.isLoading = false,
    this.error,
    this.done = false,
    this.schools = const [],
  });

  final bool isLoading;
  final String? error;
  final bool done;
  final List<Map<String, String>> schools; // [{id, name}]

  _OnboardingState copyWith({
    bool? isLoading,
    String? error,
    bool? done,
    List<Map<String, String>>? schools,
  }) =>
      _OnboardingState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        done: done ?? this.done,
        schools: schools ?? this.schools,
      );
}

class _ChildSubmission {
  const _ChildSubmission({required this.name, required this.grade, required this.requestedStop});
  final String name;
  final String grade;
  final String requestedStop;
}

class _OnboardingNotifier extends Notifier<_OnboardingState> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  _OnboardingState build() {
    _loadSchools();
    return const _OnboardingState();
  }

  Future<void> _loadSchools() async {
    try {
      final snap = await _firestore.collection(FirebaseCollections.schools).get();
      final schools = snap.docs
          .map((d) => {'id': d.id, 'name': (d.data()['name'] as String?) ?? d.id})
          .toList();
      state = state.copyWith(schools: schools);
    } catch (_) {}
  }

  Future<void> submit({
    required String parentName,
    required String phone,
    required String schoolId,
    required List<_ChildSubmission> children,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');

      await _firestore.collection(FirebaseCollections.users).doc(uid).set({
        'name': parentName.trim(),
        'phone': phone.trim(),
        'schoolId': schoolId,
        'onboardingComplete': true,
      }, SetOptions(merge: true));

      for (final child in children) {
        await _firestore.collection(FirebaseCollections.students).add({
          'name': child.name.trim(),
          'grade': child.grade.trim(),
          'schoolId': schoolId,
          'parentId': uid,
          'status': 'pending',
          'requestedStop': child.requestedStop.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      state = state.copyWith(isLoading: false, done: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ParentOnboardingScreen extends ConsumerStatefulWidget {
  const ParentOnboardingScreen({super.key});

  @override
  ConsumerState<ParentOnboardingScreen> createState() =>
      _ParentOnboardingScreenState();
}

class _ChildFormEntry {
  _ChildFormEntry()
      : nameCtrl = TextEditingController(),
        gradeCtrl = TextEditingController(),
        stopCtrl = TextEditingController();

  final TextEditingController nameCtrl;
  final TextEditingController gradeCtrl;
  final TextEditingController stopCtrl;

  void dispose() {
    nameCtrl.dispose();
    gradeCtrl.dispose();
    stopCtrl.dispose();
  }
}

class _ParentOnboardingScreenState
    extends ConsumerState<ParentOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final List<_ChildFormEntry> _children = [_ChildFormEntry()];
  String? _selectedSchoolId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    for (final c in _children) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_onboardingProvider);

    ref.listen<_OnboardingState>(_onboardingProvider, (_, next) {
      if (next.done) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          ParentRoutes.pending,
          (_) => false,
        );
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: ParentUiColors.danger,
          ),
        );
      }
    });

    if (state.done) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/auth/login',
                  (_) => false,
                );
              }
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ParentUiSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to SafeRide!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tell us about yourself and your child(ren) to get started.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: ParentUiSpacing.lg),
                _SectionLabel('Your Information'),
                const SizedBox(height: ParentUiSpacing.sm),
                _Field(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: ParentUiSpacing.sm),
                _Field(
                  controller: _phoneCtrl,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: ParentUiSpacing.sm),
                _SchoolDropdown(
                  schools: state.schools,
                  value: _selectedSchoolId,
                  onChanged: (v) => setState(() => _selectedSchoolId = v),
                ),
                const SizedBox(height: ParentUiSpacing.lg),
                Row(
                  children: [
                    _SectionLabel("Children's Information"),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _children.add(_ChildFormEntry())),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Add another child'),
                    ),
                  ],
                ),
                const SizedBox(height: ParentUiSpacing.sm),
                for (var i = 0; i < _children.length; i++)
                  _ChildEntryCard(
                    entry: _children[i],
                    index: i,
                    canRemove: _children.length > 1,
                    onRemove: () => setState(() => _children.removeAt(i)),
                  ),
                const SizedBox(height: ParentUiSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ParentUiColors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ParentUiRadius.md),
                      ),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit for Approval',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a school')),
      );
      return;
    }

    ref.read(_onboardingProvider.notifier).submit(
          parentName: _nameCtrl.text,
          phone: _phoneCtrl.text,
          schoolId: _selectedSchoolId!,
          children: _children
              .map((c) => _ChildSubmission(
                    name: c.nameCtrl.text,
                    grade: c.gradeCtrl.text,
                    requestedStop: c.stopCtrl.text,
                  ))
              .toList(),
        );
  }
}

// ---------------------------------------------------------------------------
// Pending approval screen
// ---------------------------------------------------------------------------

final _pendingChildrenProvider = StreamProvider.autoDispose((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
  return FirebaseFirestore.instance
      .collection(FirebaseCollections.students)
      .where('parentId', isEqualTo: uid)
      .snapshots();
});

class ParentPendingScreen extends ConsumerWidget {
  const ParentPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(_pendingChildrenProvider);

    ref.listen(_pendingChildrenProvider, (_, next) {
      next.whenData((snapshot) {
        final anyApproved =
            snapshot.docs.any((d) => d.data()['status'] == 'approved');
        if (anyApproved) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            ParentRoutes.home,
            (_) => false,
          );
        }
      });
    });

    return Scaffold(
      backgroundColor: ParentUiColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(ParentUiSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: ParentUiColors.lightOrange,
                    borderRadius: BorderRadius.circular(ParentUiRadius.lg),
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: ParentUiColors.orange,
                    size: 44,
                  ),
                ),
                const SizedBox(height: ParentUiSpacing.lg),
                const Text(
                  'Waiting for Approval',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ParentUiSpacing.sm),
                Text(
                  'Your child\'s registration has been submitted. '
                  'The school administrator will review and approve it shortly. '
                  'This screen will update automatically once approved.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ParentUiSpacing.lg),
                childrenAsync.when(
                  data: (snapshot) => const Icon(
                    Icons.wifi_tethering_rounded,
                    color: ParentUiColors.orange,
                    size: 20,
                  ),
                  loading: () => const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: ParentUiSpacing.xl),
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/auth/login',
                        (_) => false,
                      );
                    }
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ParentUiRadius.sm),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class _SchoolDropdown extends StatelessWidget {
  const _SchoolDropdown({
    required this.schools,
    required this.value,
    required this.onChanged,
  });

  final List<Map<String, String>> schools;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (schools.isEmpty) {
      return const Text('Loading schools…');
    }
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: 'Select School',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ParentUiRadius.sm),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: schools
          .map((s) => DropdownMenuItem(value: s['id'], child: Text(s['name']!)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Please select a school' : null,
    );
  }
}

class _ChildEntryCard extends StatelessWidget {
  const _ChildEntryCard({
    required this.entry,
    required this.index,
    required this.canRemove,
    required this.onRemove,
  });

  final _ChildFormEntry entry;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: ParentUiSpacing.md),
      padding: const EdgeInsets.all(ParentUiSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ParentUiRadius.md),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Child ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: ParentUiSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListenableBuilder(
                listenable: entry.nameCtrl,
                builder: (context, _) => CircleAvatar(
                  radius: 32,
                  backgroundColor: ParentUiColors.lightOrange,
                  child: Text(
                    initialsFor(entry.nameCtrl.text.isEmpty ? '?' : entry.nameCtrl.text),
                    style: const TextStyle(
                      color: ParentUiColors.orange,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ParentUiSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    _Field(
                      controller: entry.nameCtrl,
                      label: "Child's Full Name",
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: ParentUiSpacing.sm),
                    _Field(
                      controller: entry.gradeCtrl,
                      label: 'Grade / Class',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: ParentUiSpacing.sm),
                    _Field(
                      controller: entry.stopCtrl,
                      label: 'Pickup location (e.g. nearest landmark)',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
