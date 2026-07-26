class ParentProfileEntity {
  const ParentProfileEntity({
    required this.parentId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.homeAddress,
    required this.preferredLanguage,
  });

  final String parentId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String homeAddress;
  final String preferredLanguage;

  ParentProfileEntity copyWith({
    String? parentId,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? homeAddress,
    String? preferredLanguage,
  }) {
    return ParentProfileEntity(
      parentId: parentId ?? this.parentId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      homeAddress: homeAddress ?? this.homeAddress,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
}
