import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/parent_child_entity.dart';

final parentChildrenProvider =
    NotifierProvider<ParentChildrenController, List<ParentChildEntity>>(
      ParentChildrenController.new,
    );

class ParentChildrenController extends Notifier<List<ParentChildEntity>> {
  @override
  List<ParentChildEntity> build() {
    return const [
      ParentChildEntity(
        id: 'child_001',
        fullName: 'Ineza Uwase',
        grade: 'Primary 4',
        busNumber: 'Bus #12',
        pickupStop: 'Kacyiru',
      ),
      ParentChildEntity(
        id: 'child_002',
        fullName: 'Ganza Ntwali',
        grade: 'Primary 1',
        busNumber: 'Bus #12',
        pickupStop: 'Gishushu',
      ),
    ];
  }

  void addChild({
    required String fullName,
    required String grade,
    required String busNumber,
    required String pickupStop,
  }) {
    final newChild = ParentChildEntity(
      id: 'child_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      grade: grade,
      busNumber: busNumber,
      pickupStop: pickupStop,
    );

    state = [...state, newChild];
  }

  void updateChild(ParentChildEntity updatedChild) {
    state = [
      for (final child in state)
        if (child.id == updatedChild.id) updatedChild else child,
    ];
  }

  void removeChild(String childId) {
    state = state.where((child) => child.id != childId).toList();
  }
}
