import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/building.dart';
import '../models/poi.dart';
import '../models/room.dart';
import '../utils/mock_data.dart';
import '../utils/constants.dart';
import 'building_detail_screen.dart';
import 'search_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Building> _buildings = [];
  List<PointOfInterest> _pois = [];
  Building? _selectedBuilding;
  
  // Filter states
  Set<BuildingType> _selectedFilters = {};
  bool _showPOIs = true;
  bool _showOccupancy = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  void _loadMapData() {
    setState(() {
      _buildings = MockData.getBuildings();
      _pois = MockData.getPOIs();
    });
  }

  List<Marker> _createMarkers() {
    final markers = <Marker>[];

    // Building markers with occupancy
    for (var building in _buildings) {
      if (_selectedFilters.isNotEmpty && !_selectedFilters.contains(building.type)) {
        continue;
      }

      final rooms = MockData.getRoomsByBuildingId(building.id);
      final avgOccupancy = _calculateBuildingOccupancy(rooms);

      markers.add(
        Marker(
          point: building.position,
          width: 60,
          height: 80,
          // FIXED: Changed 'builder' to 'child'
          child: GestureDetector(
            onTap: () => _onMarkerTapped(building),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedBuilding?.id == building.id
                            ? AppConstants.secondaryColor
                            : _getBuildingMarkerColor(building.type),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getBuildingIcon(building.type),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    if (_showOccupancy && rooms.isNotEmpty)
                      Positioned(
                        top: -5,
                        right: -5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getOccupancyColor(avgOccupancy),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            '${avgOccupancy.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    building.name.split(' ').first,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // POI markers
    if (_showPOIs) {
      for (var poi in _pois) {
        markers.add(
          Marker(
            point: poi.position,
            width: 40,
            height: 40,
            // FIXED: Changed 'builder' to 'child'
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                _getPOIIcon(poi.type),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  double _calculateBuildingOccupancy(List<Room> rooms) {
    if (rooms.isEmpty) return 0;
    final totalCapacity = rooms.fold<int>(0, (sum, room) => sum + room.capacity);
    final totalOccupancy = rooms.fold<int>(0, (sum, room) => sum + room.currentOccupancy);
    return totalCapacity > 0 ? (totalOccupancy / totalCapacity * 100) : 0;
  }

  Color _getOccupancyColor(double percentage) {
    if (percentage < 50) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
  }

  Color _getBuildingMarkerColor(BuildingType type) {
    return AppConstants.buildingColors[type.name] ?? AppConstants.primaryColor;
  }

  IconData _getBuildingIcon(BuildingType type) {
    switch (type) {
      case BuildingType.classroom:
        return Icons.school;
      case BuildingType.administration:
        return Icons.business;
      case BuildingType.library:
        return Icons.local_library;
      case BuildingType.restaurant:
        return Icons.restaurant;
      case BuildingType.lab:
        return Icons.science;
      case BuildingType.sports:
        return Icons.sports_soccer;
    }
  }

  IconData _getPOIIcon(POIType type) {
    switch (type) {
      case POIType.parking:
        return Icons.local_parking;
      case POIType.entrance:
        return Icons.login;
      case POIType.exit:
        return Icons.logout;
      case POIType.toilet:
        return Icons.wc;
      case POIType.atm:
        return Icons.atm;
      case POIType.printer:
        return Icons.print;
      case POIType.wifi:
        return Icons.wifi;
      case POIType.cafeteria:
        return Icons.local_cafe;
      case POIType.other:
        return Icons.place;
    }
  }

  void _onMarkerTapped(Building building) {
    setState(() {
      _selectedBuilding = building;
    });
    _showBuildingBottomSheet(building);
  }

  void _showBuildingBottomSheet(Building building) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBuildingInfoSheet(building),
    );
  }

  Widget _buildBuildingInfoSheet(Building building) {
    final rooms = MockData.getRoomsByBuildingId(building.id);
    final avgOccupancy = _calculateBuildingOccupancy(rooms);
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getBuildingMarkerColor(building.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getBuildingIcon(building.type),
                  color: _getBuildingMarkerColor(building.type),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      building.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      building.typeLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            building.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          
          if (rooms.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getOccupancyColor(avgOccupancy).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getOccupancyColor(avgOccupancy).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: _getOccupancyColor(avgOccupancy),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Occupation moyenne: ${avgOccupancy.toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getOccupancyColor(avgOccupancy),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToBuilding(building);
                  },
                  icon: const Icon(Icons.info),
                  label: const Text('Détails'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Implement navigation
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Itinéraire'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToBuilding(Building building) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildingDetailScreen(building: building),
      ),
    );
  }

  void _openSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );

    if (result != null && result is Building) {
      _mapController.move(result.position, 18);
      setState(() {
        _selectedBuilding = result;
      });
      _showBuildingBottomSheet(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // FIXED: Changed 'center' to 'initialCenter'
              initialCenter: AppConstants.campusCenter,
              // FIXED: Changed 'zoom' to 'initialZoom'
              initialZoom: AppConstants.defaultZoom,
              minZoom: 15,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.smart_campus_map',
              ),
              MarkerLayer(
                markers: _createMarkers(),
              ),
            ],
          ),
          
          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: InkWell(
                onTap: _openSearch,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 12),
                      Text(
                        'Rechercher un bâtiment...',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Filter chips
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 0,
            right: 0,
            child: _buildFilterChips(),
          ),
          
          // Occupancy toggle
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'occupancy',
              onPressed: () {
                setState(() => _showOccupancy = !_showOccupancy);
              },
              backgroundColor: _showOccupancy ? AppConstants.primaryColor : Colors.grey,
              child: const Icon(Icons.people, size: 20),
            ),
          ),
          
          // Center button
          Positioned(
            bottom: 150,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'center',
              onPressed: () {
                _mapController.move(AppConstants.campusCenter, AppConstants.defaultZoom);
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ...BuildingType.values.map((type) {
            final isSelected = _selectedFilters.contains(type);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getBuildingIcon(type),
                      size: 16,
                      color: isSelected ? Colors.white : AppConstants.buildingColors[type.name],
                    ),
                    const SizedBox(width: 4),
                    Text(_getTypeLabel(type)),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFilters.add(type);
                    } else {
                      _selectedFilters.remove(type);
                    }
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: AppConstants.buildingColors[type.name],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            );
          }),
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.place,
                  size: 16,
                  color: _showPOIs ? Colors.white : Colors.purple,
                ),
                const SizedBox(width: 4),
                const Text('POIs'),
              ],
            ),
            selected: _showPOIs,
            onSelected: (selected) {
              setState(() => _showPOIs = selected);
            },
            backgroundColor: Colors.white,
            selectedColor: Colors.purple,
            labelStyle: TextStyle(
              color: _showPOIs ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(BuildingType type) {
    switch (type) {
      case BuildingType.classroom:
        return 'Cours';
      case BuildingType.administration:
        return 'Admin';
      case BuildingType.library:
        return 'Biblio';
      case BuildingType.restaurant:
        return 'Restau';
      case BuildingType.lab:
        return 'Lab';
      case BuildingType.sports:
        return 'Sport';
    }
  }
}