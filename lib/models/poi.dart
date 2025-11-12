import 'package:latlong2/latlong.dart';

enum POICategory {
  parking,      // 🅿️ Parking
  entrance,     // 🚪 Entrance
  exit,         // 🚪 Exit
  toilet,       // 🚻 Toilettes
  atm,          // 🏧 ATM
  printer,      // 🖨️ Printer
  wifi,         // 📶 WiFi Zone
  cafeteria,    // 🍕 Cafeteria
  study,        // 📚 Study spot
  sports,       // ⚽ Sports
  emergency,    // 🚨 Emergency
  other,        // 📍 Other
}

// Keep old class for backward compatibility
class PointOfInterest {
  final String id;
  final String name;
  final POIType type;
  final LatLng position;
  final String? description;
  final String? iconPath;

  PointOfInterest({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.description,
    this.iconPath,
  });

  String get typeLabel {
    switch (type) {
      case POIType.parking:
        return 'Parking';
      case POIType.entrance:
        return 'Entrée';
      case POIType.exit:
        return 'Sortie';
      case POIType.toilet:
        return 'Toilettes';
      case POIType.atm:
        return 'ATM';
      case POIType.printer:
        return 'Imprimante';
      case POIType.wifi:
        return 'Zone WiFi';
      case POIType.cafeteria:
        return 'Cafétéria';
      case POIType.other:
        return 'Autre';
    }
  }
}

enum POIType {
  parking,
  entrance,
  exit,
  toilet,
  atm,
  printer,
  wifi,
  cafeteria,
  other,
}

// ✅ NEW: POI class for CRUD operations
class POI {
  final String id;
  final String name;
  final String description;
  final LatLng position;
  final POICategory category;
  final String icon;

  POI({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
    required this.category,
    required this.icon,
  });

  // Get category label in French
  String get categoryLabel {
    switch (category) {
      case POICategory.parking:
        return 'Parking';
      case POICategory.entrance:
        return 'Entrée';
      case POICategory.exit:
        return 'Sortie';
      case POICategory.toilet:
        return 'Toilettes';
      case POICategory.atm:
        return 'Distributeur';
      case POICategory.printer:
        return 'Imprimante';
      case POICategory.wifi:
        return 'Zone WiFi';
      case POICategory.cafeteria:
        return 'Cafétéria';
      case POICategory.study:
        return 'Espace étude';
      case POICategory.sports:
        return 'Sports';
      case POICategory.emergency:
        return 'Urgence';
      case POICategory.other:
        return 'Autre';
    }
  }

  // Get category emoji icon
  String get categoryIcon {
    switch (category) {
      case POICategory.parking:
        return '🅿️';
      case POICategory.entrance:
        return '🚪';
      case POICategory.exit:
        return '🚪';
      case POICategory.toilet:
        return '🚻';
      case POICategory.atm:
        return '🏧';
      case POICategory.printer:
        return '🖨️';
      case POICategory.wifi:
        return '📶';
      case POICategory.cafeteria:
        return '🍕';
      case POICategory.study:
        return '📚';
      case POICategory.sports:
        return '⚽';
      case POICategory.emergency:
        return '🚨';
      case POICategory.other:
        return '📍';
    }
  }

  // Get category color
  String get categoryColor {
    switch (category) {
      case POICategory.parking:
        return '#764BA2';
      case POICategory.entrance:
        return '#4ECDC4';
      case POICategory.exit:
        return '#F6AD55';
      case POICategory.toilet:
        return '#38A169';
      case POICategory.atm:
        return '#4ECDC4';
      case POICategory.printer:
        return '#95E1D3';
      case POICategory.wifi:
        return '#667EEA';
      case POICategory.cafeteria:
        return '#FF6B6B';
      case POICategory.study:
        return '#667EEA';
      case POICategory.sports:
        return '#FC8181';
      case POICategory.emergency:
        return '#F56565';
      case POICategory.other:
        return '#A0AEC0';
    }
  }

  // Copy with method for updates
  POI copyWith({
    String? id,
    String? name,
    String? description,
    LatLng? position,
    POICategory? category,
    String? icon,
  }) {
    return POI(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      position: position ?? this.position,
      category: category ?? this.category,
      icon: icon ?? this.icon,
    );
  }

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'category': category.toString().split('.').last,
      'icon': icon,
    };
  }

  // Create from Map (from SQLite)
  factory POI.fromMap(Map<String, dynamic> map) {
    return POI(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      position: LatLng(map['latitude'], map['longitude']),
      category: POICategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => POICategory.other,
      ),
      icon: map['icon'],
    );
  }
}