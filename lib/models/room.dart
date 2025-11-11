class Room {
  final String id;
  final String buildingId;
  final String name;
  final String roomNumber;
  final int capacity;
  final List<String> equipment;
  final bool isAvailable;
  final String? currentOccupation;
  final int floorNumber; // NEW: Which floor is this room on?
  final int currentOccupancy; // NEW: Current number of people
  final DateTime? occupancyLastUpdated; // NEW: When was occupancy last checked

  Room({
    required this.id,
    required this.buildingId,
    required this.name,
    required this.roomNumber,
    required this.capacity,
    required this.equipment,
    this.isAvailable = true,
    this.currentOccupation,
    this.floorNumber = 0, // NEW
    this.currentOccupancy = 0, // NEW
    this.occupancyLastUpdated, // NEW
  });

  // NEW: Calculate occupancy percentage
  double get occupancyPercentage {
    if (capacity == 0) return 0;
    return (currentOccupancy / capacity * 100).clamp(0, 100);
  }

  // NEW: Get occupancy status
  String get occupancyStatus {
    final percentage = occupancyPercentage;
    if (percentage < 50) return 'Faible';
    if (percentage < 80) return 'Moyenne';
    return 'Élevée';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buildingId': buildingId,
      'name': name,
      'roomNumber': roomNumber,
      'capacity': capacity,
      'equipment': equipment,
      'isAvailable': isAvailable,
      'currentOccupation': currentOccupation,
      'floorNumber': floorNumber, // NEW
      'currentOccupancy': currentOccupancy, // NEW
      'occupancyLastUpdated': occupancyLastUpdated?.toIso8601String(), // NEW
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      buildingId: json['buildingId'],
      name: json['name'],
      roomNumber: json['roomNumber'],
      capacity: json['capacity'],
      equipment: List<String>.from(json['equipment']),
      isAvailable: json['isAvailable'] ?? true,
      currentOccupation: json['currentOccupation'],
      floorNumber: json['floorNumber'] ?? 0, // NEW
      currentOccupancy: json['currentOccupancy'] ?? 0, // NEW
      occupancyLastUpdated: json['occupancyLastUpdated'] != null // NEW
          ? DateTime.parse(json['occupancyLastUpdated'])
          : null,
    );
  }
}