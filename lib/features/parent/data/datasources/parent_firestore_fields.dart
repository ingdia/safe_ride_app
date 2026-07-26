class ParentTripFields {
  const ParentTripFields._();

  static const String childName = 'childName';
  static const String schoolName = 'schoolName';
  static const String grade = 'grade';
  static const String busNumber = 'busNumber';
  static const String driverName = 'driverName';
  static const String currentStop = 'currentStop';
  static const String nextStop = 'nextStop';
  static const String eta = 'eta';
  static const String stopsAway = 'stopsAway';
  static const String progress = 'progress';
  static const String status = 'status';
  static const String routeStops = 'routeStops';
  static const String busLocation = 'busLocation';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String lastUpdatedAt = 'lastUpdatedAt';

  static const String stopId = 'id';
  static const String stopName = 'name';
  static const String stopTime = 'time';
  static const String stopPosition = 'position';
}

class ParentProfileFields {
  const ParentProfileFields._();

  static const String fullName = 'fullName';
  static const String phoneNumber = 'phoneNumber';
  static const String email = 'email';
  static const String homeAddress = 'homeAddress';
  static const String preferredLanguage = 'preferredLanguage';
  static const String updatedAt = 'updatedAt';
}

class ParentChildFields {
  const ParentChildFields._();

  static const String fullName = 'fullName';
  static const String grade = 'grade';
  static const String busNumber = 'busNumber';
  static const String pickupStop = 'pickupStop';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
}

class ParentNotificationFields {
  const ParentNotificationFields._();

  static const String parentId = 'parentId';
  static const String title = 'title';
  static const String message = 'message';
  static const String type = 'type';
  static const String isRead = 'isRead';
  static const String createdAt = 'createdAt';
  static const String readAt = 'readAt';
}
