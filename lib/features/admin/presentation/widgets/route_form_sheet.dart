import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/route_model.dart';
import '../providers/buses_provider.dart';
import 'admin_ui_constants.dart';

class RouteFormSheet extends ConsumerStatefulWidget {
  final RouteModel? existingRoute;
  final String schoolId;

  const RouteFormSheet({
    super.key,
    this.existingRoute,
    required this.schoolId,
  });

  static Future<RouteModel?> show(
    BuildContext context, {
    RouteModel? existingRoute,
    required String schoolId,
  }) {
    return showModalBottomSheet<RouteModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RouteFormSheet(
        existingRoute: existingRoute,
        schoolId: schoolId,
      ),
    );
  }

  @override
  ConsumerState<RouteFormSheet> createState() => _RouteFormSheetState();
}

class _RouteFormSheetState extends ConsumerState<RouteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String? _selectedBusId;
  late List<TextEditingController> _stopControllers;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingRoute?.name ?? '');
    _selectedBusId = widget.existingRoute?.busId;
    final existingStops = widget.existingRoute?.stops ?? const [];
    _stopControllers = existingStops.isEmpty
        ? [TextEditingController()]
        : existingStops.map((s) => TextEditingController(text: s.name)).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _stopControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addStopField() {
    setState(() => _stopControllers.add(TextEditingController()));
  }

  void _removeStopField(int index) {
    setState(() {
      final removed = _stopControllers.removeAt(index);
      removed.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final buses = ref.watch(busesProvider);
    final isEditing = widget.existingRoute != null;
    final validBusId =
        buses.any((b) => b.busId == _selectedBusId) ? _selectedBusId : null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
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
              child: ListView(
                controller: scrollController,
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
                    isEditing ? 'Edit Route' : 'Create New Route',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AdminUiSpacing.md),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Route Name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Route name is required'
                        : null,
                  ),
                  const SizedBox(height: AdminUiSpacing.sm),
                  DropdownButtonFormField<String>(
                    value: validBusId,
                    decoration: const InputDecoration(labelText: 'Assigned Bus'),
                    items: buses
                        .map(
                          (b) => DropdownMenuItem(
                            value: b.busId,
                            child: Text('Bus ${b.plateNumber}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selectedBusId = value),
                    validator: (v) => v == null ? 'Select a bus' : null,
                  ),
                  const SizedBox(height: AdminUiSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Stops',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addStopField,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Stop'),
                      ),
                    ],
                  ),
                  for (var i = 0; i < _stopControllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AdminUiSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stopControllers[i],
                              decoration:
                                  InputDecoration(labelText: 'Stop ${i + 1} Name'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          if (_stopControllers.length > 1)
                            IconButton(
                              onPressed: () => _removeStopField(i),
                              icon: const Icon(
                                Icons.close,
                                color: AdminUiColors.delayedFg,
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AdminUiSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(isEditing ? 'Save Changes' : 'Create Route'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final stops = <RouteStop>[
      for (var i = 0; i < _stopControllers.length; i++)
        RouteStop(
          name: _stopControllers[i].text.trim(),
          lat: 40.0701 + (i * 0.0001),
          lng: -73.0901 - (i * 0.0001),
          order: i + 1,
        ),
    ];
    final route = RouteModel(
      routeId: widget.existingRoute?.routeId ??
          'route-${DateTime.now().microsecondsSinceEpoch}',
      schoolId: widget.schoolId,
      busId: _selectedBusId!,
      name: _nameController.text.trim(),
      stops: stops,
    );
    Navigator.of(context).pop(route);
  }
}
