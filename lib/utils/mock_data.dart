import 'package:latlong2/latlong.dart';
import '../models/building.dart';
import '../models/room.dart';
import '../models/poi.dart';
import '../models/floor_plan.dart'; // NEW
import 'dart:ui'; // NEW

class MockData {
  static const LatLng campusCenter = LatLng(36.8981, 10.1897);

  // BUILDINGS DATA - UPDATED with floor information
  static List<Building> getBuildings() {
    return [
      Building(
        id: '1',
        name: 'Bloc A - Administration',
        type: BuildingType.administration,
        position: const LatLng(36.8985, 10.1900),
        description: 'Services administratifs, direction, scolarité',
        rooms: ['A101', 'A102', 'A201', 'A202'],
        numberOfFloors: 2, // NEW
        hasIndoorMap: true, // NEW
      ),
      Building(
        id: '2',
        name: 'Bloc B - Salles de cours',
        type: BuildingType.classroom,
        position: const LatLng(36.8980, 10.1895),
        description: 'Amphithéâtres et salles de cours',
        rooms: ['B101', 'B102', 'B103', 'B201', 'B202', 'B203'],
        numberOfFloors: 3, // NEW
        hasIndoorMap: true, // NEW
      ),
      Building(
        id: '3',
        name: 'Bibliothèque Centrale',
        type: BuildingType.library,
        position: const LatLng(36.8975, 10.1892),
        description: 'Bibliothèque universitaire avec espace d\'étude',
        rooms: ['Salle de lecture', 'Espace numérique', 'Salle de groupe'],
        numberOfFloors: 2, // NEW
        hasIndoorMap: true, // NEW
      ),
      Building(
        id: '4',
        name: 'Cafétéria Universitaire',
        type: BuildingType.restaurant,
        position: const LatLng(36.8978, 10.1888),
        description: 'Restaurant et cafétéria pour étudiants et personnel',
        rooms: ['Cafétéria', 'Restaurant principal', 'Espace terrasse'],
        numberOfFloors: 1, // NEW
        hasIndoorMap: false, // NEW
      ),
      Building(
        id: '5',
        name: 'Laboratoires Informatiques',
        type: BuildingType.lab,
        position: const LatLng(36.8988, 10.1903),
        description: 'Laboratoires équipés pour travaux pratiques',
        rooms: ['Lab 1', 'Lab 2', 'Lab 3', 'Lab Réseau'],
        numberOfFloors: 2, // NEW
        hasIndoorMap: true, // NEW
      ),
      Building(
        id: '6',
        name: 'Complexe Sportif',
        type: BuildingType.sports,
        position: const LatLng(36.8972, 10.1905),
        description: 'Installations sportives et salle de gym',
        rooms: ['Gymnase', 'Terrain de foot', 'Salle de musculation'],
        numberOfFloors: 1, // NEW
        hasIndoorMap: false, // NEW
      ),
    ];
  }

  // ROOMS DATA - UPDATED with occupancy
  static List<Room> getRooms() {
    final now = DateTime.now();
    return [
      Room(
        id: 'r1',
        buildingId: '2',
        name: 'Amphithéâtre B101',
        roomNumber: 'B101',
        capacity: 120,
        equipment: ['Projecteur', 'Micro', 'Tableau interactif'],
        isAvailable: false,
        currentOccupation: 'Cours: Développement Mobile (09:00 - 11:00)',
        floorNumber: 1, // NEW
        currentOccupancy: 85, // NEW
        occupancyLastUpdated: now, // NEW
      ),
      Room(
        id: 'r2',
        buildingId: '2',
        name: 'Salle B102',
        roomNumber: 'B102',
        capacity: 30,
        equipment: ['Projecteur', 'Tableau blanc'],
        isAvailable: true,
        floorNumber: 1, // NEW
        currentOccupancy: 0, // NEW
        occupancyLastUpdated: now, // NEW
      ),
      Room(
        id: 'r3',
        buildingId: '3',
        name: 'Salle de lecture',
        roomNumber: 'L101',
        capacity: 50,
        equipment: ['WiFi', 'Prises électriques', 'Lumière naturelle'],
        isAvailable: true,
        floorNumber: 1, // NEW
        currentOccupancy: 22, // NEW
        occupancyLastUpdated: now, // NEW
      ),
      Room(
        id: 'r4',
        buildingId: '5',
        name: 'Laboratoire 1',
        roomNumber: 'Lab1',
        capacity: 25,
        equipment: ['PC', 'Logiciels dev', 'Réseau local'],
        isAvailable: false,
        currentOccupation: 'Réservée par: Groupe Projet PFE',
        floorNumber: 1, // NEW
        currentOccupancy: 18, // NEW
        occupancyLastUpdated: now, // NEW
      ),
    ];
  }

  // NEW: Floor plans for buildings
  static List<FloorPlan> getFloorPlans(String buildingId) {
    // Simplified floor plans with room polygons
    if (buildingId == '2') {
      // Bloc B - Floor 1
      return [
        FloorPlan(
          id: 'fp_b_1',
          buildingId: '2',
          floorNumber: 1,
          floorName: 'Rez-de-chaussée',
          roomPolygons: [
            RoomPolygon(
              roomId: 'r1',
              roomNumber: 'B101',
              coordinates: [
                const Offset(50, 50),
                const Offset(200, 50),
                const Offset(200, 150),
                const Offset(50, 150),
              ],
              center: const Offset(125, 100),
            ),
            RoomPolygon(
              roomId: 'r2',
              roomNumber: 'B102',
              coordinates: [
                const Offset(220, 50),
                const Offset(350, 50),
                const Offset(350, 150),
                const Offset(220, 150),
              ],
              center: const Offset(285, 100),
            ),
          ],
        ),
      ];
    }
    return [];
  }

  // POINTS OF INTEREST - unchanged
  static List<PointOfInterest> getPOIs() {
    return [
      PointOfInterest(
        id: 'poi1',
        name: 'Entrée Principale',
        type: POIType.entrance,
        position: const LatLng(36.8983, 10.1894),
        description: 'Entrée principale du campus avec contrôle d\'accès',
      ),
      PointOfInterest(
        id: 'poi2',
        name: 'Parking Étudiant',
        type: POIType.parking,
        position: const LatLng(36.8970, 10.1890),
        description: 'Parking gratuit pour étudiants - 200 places',
      ),
      PointOfInterest(
        id: 'poi3',
        name: 'Distributeur ATM',
        type: POIType.atm,
        position: const LatLng(36.8979, 10.1896),
        description: 'Distributeur automatique de billets',
      ),
      PointOfInterest(
        id: 'poi4',
        name: 'Zone WiFi Extérieure',
        type: POIType.wifi,
        position: const LatLng(36.8982, 10.1899),
        description: 'Espace extérieur avec WiFi gratuit',
      ),
      PointOfInterest(
        id: 'poi5',
        name: 'Service Impression',
        type: POIType.printer,
        position: const LatLng(36.8986, 10.1898),
        description: 'Service d\'impression et photocopie',
      ),
    ];
  }

  static List<Room> getRoomsByBuildingId(String buildingId) {
    return getRooms().where((room) => room.buildingId == buildingId).toList();
  }

  static List<Building> searchBuildings(String query) {
    final lowerQuery = query.toLowerCase();
    return getBuildings().where((building) {
      return building.name.toLowerCase().contains(lowerQuery) ||
             building.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}