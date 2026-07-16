import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bus_model.dart';
import '../../data/models/user_model.dart';
import '../providers/users_provider.dart';
import 'admin_ui_constants.dart';

class BusFormSheet extends ConsumerStatefulWidget {
  final BusModel? existingBus;
  final String schoolId;

  const BusFormSheet({
    super.key,
    this.existingBus,
    required this.schoolId,
  });

  static Future<BusModel?> show(
    BuildContext context, {
    BusModel? existingBus,
    required String schoolId,
  }) {
    return showModalBottomSheet<BusModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BusFormSheet(
        existingBus: existingBus,
        schoolId: schoolId,
      ),
    );
  }

  @override
  ConsumerState<BusFormSheet> createState() => _BusFormSheetState();
}

class _BusFormSheetState extends ConsumerState<BusFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateController;
  late final TextEditingController _capacityController;
  String? _selectedDriverId;

  @override
  void initState() {
    super.initState();
    _plateController =
        TextEditingController(text: widget.existingBus?.plateNumber ?? '');
    _capacityController = TextEditingController(
      text: widget.existingBus?.capacity.toString() ?? '',
    );
    _selectedDriverId = widget.existingBus?.driverId;
  }

  @override
  void dispose() {
    _plateController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drivers = ref
        .watch(usersProvider)
        .where((u) => u.role == UserRole.driver)
        .toList();
    final isEditing = widget.existingBus != null;
    final validDriverId =
        drivers.any((d) => d.userId == _selectedDriverId)
            ? _selectedDriverId
            : null;

    // Bottom sheets have a fixed height budget, and that budget shrinks a
    // lot in landscape mode or when the keyboard is open. Wrapping the form
    // in a SingleChildScrollView (instead of a bare, non-scrolling Column)
    // prevents a RenderFlex "bottom overflowed" error in those cases.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.fromLTRB(
          AdminUiSpacing.md,
          AdminUiSpacing.md,
          AdminUiSpacing.md,
          AdminUiSpacing.lg,
        ),
        decoration: const BoxDecoration(
          color: AdminUiColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AdminUiSpacing.md),
                  decoration: BoxDecoration(
                    color: AdminUiColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                isEditing ? 'Edit Bus' : 'Add New Bus',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AdminUiSpacing.md),
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(labelText: 'Plate Number'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Plate number is required'
                    : null,
              ),
              const SizedBox(height: AdminUiSpacing.sm),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacity'),
                validator: (v) {
                  final parsed = int.tryParse(v ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid capacity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AdminUiSpacing.sm),
              DropdownButtonFormField<String>(
                value: validDriverId,
                decoration: const InputDecoration(labelText: 'Assigned Driver'),
                items: drivers
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.userId,
                        child: Text(d.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedDriverId = value),
                validator: (v) => v == null ? 'Select a driver' : null,
              ),
              const SizedBox(height: AdminUiSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEditing ? 'Save Changes' : 'Add Bus'),
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
    if (!_formKey.currentState!.validate()) return;
    final bus = BusModel(
      busId: widget.existingBus?.busId ??
          'bus-${DateTime.now().microsecondsSinceEpoch}',
      plateNumber: _plateController.text.trim(),
      capacity: int.parse(_capacityController.text.trim()),
      driverId: _selectedDriverId!,
      schoolId: widget.schoolId,
    );
    Navigator.of(context).pop(bus);
  }
}
