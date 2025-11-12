import '../models/poi.dart';
import 'database_helper.dart';
import 'package:latlong2/latlong.dart';

class POIService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ==================== CREATE ====================
  
  /// Create a new POI and save to database
  Future<bool> createPOI({
    required String name,
    required String description,
    required LatLng position,
    required POICategory category,
    String? customIcon,
  }) async {
    try {
      final poi = POI(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        position: position,
        category: category,
        icon: customIcon ?? _getDefaultIconForCategory(category),
      );

      final result = await _dbHelper.insertPoi(poi);
      
      if (result > 0) {
        print('✅ POI created successfully: ${poi.name} (${poi.id})');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error creating POI: $e');
      return false;
    }
  }

  // ==================== READ ====================
  
  /// Get all POIs from database
  Future<List<POI>> getAllPOIs() async {
    try {
      final pois = await _dbHelper.getAllPois();
      print('📍 Loaded ${pois.length} POIs from database');
      return pois;
    } catch (e) {
      print('❌ Error getting all POIs: $e');
      return [];
    }
  }

  /// Get POI by ID
  Future<POI?> getPOIById(String id) async {
    try {
      return await _dbHelper.getPoiById(id);
    } catch (e) {
      print('❌ Error getting POI by ID: $e');
      return null;
    }
  }

  /// Get POIs filtered by category
  Future<List<POI>> getPOIsByCategory(POICategory category) async {
    try {
      final allPois = await _dbHelper.getAllPois();
      return allPois.where((poi) => poi.category == category).toList();
    } catch (e) {
      print('❌ Error getting POIs by category: $e');
      return [];
    }
  }

  /// Get POIs near a location (within radius in meters)
  Future<List<POI>> getPOIsNearLocation(
    LatLng location, {
    double radiusInMeters = 1000,
  }) async {
    try {
      final allPois = await _dbHelper.getAllPois();
      final Distance distance = const Distance();

      return allPois.where((poi) {
        final distanceInMeters = distance.as(
          LengthUnit.Meter,
          location,
          poi.position,
        );
        return distanceInMeters <= radiusInMeters;
      }).toList();
    } catch (e) {
      print('❌ Error getting nearby POIs: $e');
      return [];
    }
  }

  /// Search POIs by name
  Future<List<POI>> searchPOIs(String query) async {
    try {
      if (query.isEmpty) return await getAllPOIs();

      final allPois = await _dbHelper.getAllPois();
      final lowercaseQuery = query.toLowerCase();

      return allPois.where((poi) {
        return poi.name.toLowerCase().contains(lowercaseQuery) ||
               poi.description.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      print('❌ Error searching POIs: $e');
      return [];
    }
  }

  /// Get POI count
  Future<int> getPOICount() async {
    try {
      return await _dbHelper.getPoisCount();
    } catch (e) {
      print('❌ Error getting POI count: $e');
      return 0;
    }
  }

  /// Get POIs grouped by category
  Future<Map<POICategory, List<POI>>> getPOIsGroupedByCategory() async {
    try {
      final allPois = await _dbHelper.getAllPois();
      final Map<POICategory, List<POI>> grouped = {};

      for (var category in POICategory.values) {
        grouped[category] = allPois
            .where((poi) => poi.category == category)
            .toList();
      }

      return grouped;
    } catch (e) {
      print('❌ Error grouping POIs: $e');
      return {};
    }
  }

  // ==================== UPDATE ====================
  
  /// Update an existing POI
  Future<bool> updatePOI(POI poi) async {
    try {
      final result = await _dbHelper.updatePoi(poi);
      
      if (result > 0) {
        print('✅ POI updated successfully: ${poi.name} (${poi.id})');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating POI: $e');
      return false;
    }
  }

  /// Update POI location
  Future<bool> updatePOILocation(String id, LatLng newPosition) async {
    try {
      final poi = await getPOIById(id);
      if (poi == null) return false;

      final updatedPoi = poi.copyWith(position: newPosition);
      return await updatePOI(updatedPoi);
    } catch (e) {
      print('❌ Error updating POI location: $e');
      return false;
    }
  }

  /// Update POI category
  Future<bool> updatePOICategory(String id, POICategory newCategory) async {
    try {
      final poi = await getPOIById(id);
      if (poi == null) return false;

      final updatedPoi = poi.copyWith(
        category: newCategory,
        icon: _getDefaultIconForCategory(newCategory),
      );
      return await updatePOI(updatedPoi);
    } catch (e) {
      print('❌ Error updating POI category: $e');
      return false;
    }
  }

  // ==================== DELETE ====================
  
  /// Delete a POI by ID
  Future<bool> deletePOI(String id) async {
    try {
      final result = await _dbHelper.deletePoi(id);
      
      if (result > 0) {
        print('✅ POI deleted successfully: $id');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting POI: $e');
      return false;
    }
  }

  /// Delete all POIs in a category
  Future<int> deletePOIsByCategory(POICategory category) async {
    try {
      final poisToDelete = await getPOIsByCategory(category);
      int deletedCount = 0;

      for (var poi in poisToDelete) {
        final success = await deletePOI(poi.id);
        if (success) deletedCount++;
      }

      print('✅ Deleted $deletedCount POIs in category: $category');
      return deletedCount;
    } catch (e) {
      print('❌ Error deleting POIs by category: $e');
      return 0;
    }
  }

  /// Delete all POIs (use with caution!)
  Future<bool> deleteAllPOIs() async {
    try {
      final allPois = await getAllPOIs();
      int deletedCount = 0;

      for (var poi in allPois) {
        final success = await deletePOI(poi.id);
        if (success) deletedCount++;
      }

      print('✅ Deleted all POIs: $deletedCount total');
      return deletedCount == allPois.length;
    } catch (e) {
      print('❌ Error deleting all POIs: $e');
      return false;
    }
  }

  // ==================== HELPER METHODS ====================
  
  /// Get default icon emoji for a category
  String _getDefaultIconForCategory(POICategory category) {
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

  /// Get statistics about POIs
  Future<Map<String, dynamic>> getPOIStatistics() async {
    try {
      final allPois = await getAllPOIs();
      final grouped = await getPOIsGroupedByCategory();

      final stats = {
        'total': allPois.length,
        'byCategory': grouped.map((key, value) => MapEntry(
          key.toString().split('.').last,
          value.length,
        )),
        'mostCommonCategory': _getMostCommonCategory(grouped),
      };

      return stats;
    } catch (e) {
      print('❌ Error getting POI statistics: $e');
      return {'total': 0};
    }
  }

  String _getMostCommonCategory(Map<POICategory, List<POI>> grouped) {
    if (grouped.isEmpty) return 'none';

    var maxCategory = grouped.entries.first;
    for (var entry in grouped.entries) {
      if (entry.value.length > maxCategory.value.length) {
        maxCategory = entry;
      }
    }

    return maxCategory.key.toString().split('.').last;
  }

  /// Validate POI data before saving
  bool validatePOI({
    required String name,
    required String description,
    required LatLng position,
  }) {
    if (name.trim().isEmpty) {
      print('❌ Validation failed: Name is required');
      return false;
    }

    if (name.length < 3) {
      print('❌ Validation failed: Name must be at least 3 characters');
      return false;
    }

    if (name.length > 50) {
      print('❌ Validation failed: Name must be less than 50 characters');
      return false;
    }

    if (description.length > 200) {
      print('❌ Validation failed: Description must be less than 200 characters');
      return false;
    }

    // Validate coordinates are within reasonable campus bounds
    // Adjust these based on your campus location
    if (position.latitude < -90 || position.latitude > 90) {
      print('❌ Validation failed: Invalid latitude');
      return false;
    }

    if (position.longitude < -180 || position.longitude > 180) {
      print('❌ Validation failed: Invalid longitude');
      return false;
    }

    return true;
  }
}