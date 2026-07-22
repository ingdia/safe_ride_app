class ParentChildEntity {
  const ParentChildEntity({
    required this.id,
    required this.fullName,
    required this.grade,
    required this.busNumber,
    required this.pickupStop,
  });

  final String id;
  final String fullName;
  final String grade;
  final String busNumber;
  final String pickupStop;

  ParentChildEntity copyWith({
    String? id,
    String? fullName,
    String? grade,
    String? busNumber,
    String? pickupStop,
  }) {
    return ParentChildEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      grade: grade ?? this.grade,
      busNumber: busNumber ?? this.busNumber,
      pickupStop: pickupStop ?? this.pickupStop,
    );
  }
}
