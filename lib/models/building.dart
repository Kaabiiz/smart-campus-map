import 'package:latlong2/latlong.dart';

enum BuildingType {
  classroom,
  administration,
  library,
  restaurant,
  lab,
  sports,
}

class Building {
  final String id;
  final String name;
  final BuildingType type;
  final LatLng position;
  final String description;
  final List<String> rooms;
  final String? imageUrl;
  final bool isOpen;
  final int numberOfFloors; // NEW: Number of floors in building
  final bool hasIndoorMap; // NEW: Does this building have indoor maps?

  Building({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.description,
    required this.rooms,
    this.imageUrl,
    this.isOpen = true,
    this.numberOfFloors = 1, // NEW
    this.hasIndoorMap = false, // NEW
  });

  String get typeLabel {
    switch (type) {
      case BuildingType.classroom:
        return 'Salle de cours';
      case BuildingType.administration:
        return 'Administration';
      case BuildingType.library:
        return 'Bibliothèque';
      case BuildingType.restaurant:
        return 'Restaurant';
      case BuildingType.lab:
        return 'Laboratoire';
      case BuildingType.sports:
        return 'Sports';
    }
  }
}