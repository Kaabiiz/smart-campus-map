import 'dart:ui';

class FloorPlan {
  final String id;
  final String buildingId;
  final int floorNumber;
  final String floorName;
  final String? imageUrl;
  final List<RoomPolygon> roomPolygons;

  FloorPlan({
    required this.id,
    required this.buildingId,
    required this.floorNumber,
    required this.floorName,
    this.imageUrl,
    required this.roomPolygons,
  });
}

class RoomPolygon {
  final String roomId;
  final String roomNumber;
  final List<Offset> coordinates; // Polygon points for room shape
  final Offset center; // Center point for label

  RoomPolygon({
    required this.roomId,
    required this.roomNumber,
    required this.coordinates,
    required this.center,
  });
}