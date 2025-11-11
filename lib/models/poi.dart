import 'package:latlong2/latlong.dart';

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