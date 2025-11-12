import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/building.dart';
import '../models/room.dart';
import '../models/poi.dart';
import '../services/poi_service.dart';
import '../utils/mock_data.dart';
import 'room_reservation_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final POIService _poiService = POIService();
  
  Building? _selectedBuilding;
  List<Building> _buildings = [];
  List<Room> _allRooms = [];
  List<Room> _buildingRooms = [];
  List<POI> _customPOIs = [];
  bool _showPOIs = true;
  String _searchQuery = '';
  List<Building> _filteredBuildings = [];
  List<Room> _filteredRooms = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _buildings = MockData.getBuildings();
    _allRooms = MockData.getRooms();
    await _loadCustomPOIs();
    setState(() {});
  }

  Future<void> _loadCustomPOIs() async {
    try {
      final pois = await _poiService.getAllPOIs();
      setState(() {
        _customPOIs = pois;
      });
      print('📍 Loaded ${pois.length} custom POIs');
      
      if (mounted && pois.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('💡 Aucun POI trouvé. Ajoutez-en depuis "Gérer les POI"!'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error loading POIs: $e');
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBuildings = [];
        _filteredRooms = [];
        _isSearching = false;
        return;
      }

      _isSearching = true;
      final lowerQuery = query.toLowerCase();

      _filteredBuildings = _buildings.where((building) {
        return building.name.toLowerCase().contains(lowerQuery) ||
               building.description.toLowerCase().contains(lowerQuery);
      }).toList();

      _filteredRooms = _allRooms.where((room) {
        return room.name.toLowerCase().contains(lowerQuery) ||
               room.roomNumber.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  void _selectBuilding(Building building) {
    setState(() {
      _selectedBuilding = building;
      _isSearching = false;
      _searchQuery = '';
      
      // Load rooms for this building
      _buildingRooms = _allRooms
          .where((room) => room.buildingId == building.id)
          .toList();
    });
    _mapController.move(building.position, 18);
  }

  void _selectRoom(Room room) {
    // Navigate to room reservation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomReservationScreen(room: room),
      ),
    );
  }

  void _selectPOI(POI poi) {
    setState(() {
      _selectedBuilding = null;
      _isSearching = false;
      _searchQuery = '';
    });
    _mapController.move(poi.position, 18);
    
    // Show POI details in bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color(int.parse(poi.categoryColor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(poi.icon, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poi.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(int.parse(poi.categoryColor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          poi.categoryLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(int.parse(poi.categoryColor.replaceFirst('#', '0xFF'))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (poi.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.description, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        poi.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${poi.position.latitude.toStringAsFixed(5)}, ${poi.position.longitude.toStringAsFixed(5)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Fermer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF48BB78),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBuildingColor(BuildingType type) {
    switch (type) {
      case BuildingType.classroom:
        return Colors.blue;
      case BuildingType.administration:
        return Colors.purple;
      case BuildingType.library:
        return Colors.green;
      case BuildingType.restaurant:
        return Colors.orange;
      case BuildingType.lab:
        return Colors.red;
      case BuildingType.sports:
        return Colors.teal;
    }
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

  // Helper to get room icon based on occupancy
  IconData _getRoomIcon(Room room) {
    if (!room.isAvailable) return Icons.meeting_room_outlined;
    if (room.occupancyPercentage >= 80) return Icons.group;
    if (room.occupancyPercentage >= 50) return Icons.groups;
    return Icons.meeting_room;
  }

  // Helper to get room color based on occupancy
  Color _getRoomColor(Room room) {
    if (!room.isAvailable) return Colors.grey;
    if (room.occupancyPercentage >= 80) return Colors.red;
    if (room.occupancyPercentage >= 50) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: MockData.campusCenter,
              initialZoom: 16,
              minZoom: 14,
              maxZoom: 19,
              onTap: (_, __) {
                setState(() {
                  _selectedBuilding = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.smart_campus_map',
              ),

              // Building Markers
              MarkerLayer(
                markers: _buildings.map((building) {
                  final isSelected = _selectedBuilding?.id == building.id;
                  final buildingColor = _getBuildingColor(building.type);
                  
                  return Marker(
                    point: building.position,
                    width: 140,
                    height: 90,
                    child: GestureDetector(
                      onTap: () => _selectBuilding(building),
                      child: Column(
                        children: [
                          Container(
                            width: isSelected ? 50 : 45,
                            height: isSelected ? 50 : 45,
                            decoration: BoxDecoration(
                              color: isSelected ? buildingColor : buildingColor.withOpacity(0.8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: buildingColor.withOpacity(0.4),
                                  blurRadius: isSelected ? 12 : 8,
                                  spreadRadius: isSelected ? 2 : 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              _getBuildingIcon(building.type),
                              color: Colors.white,
                              size: isSelected ? 24 : 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              building.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isSelected ? 12 : 11,
                                color: buildingColor,
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Custom POI Markers
              if (_showPOIs)
                MarkerLayer(
                  markers: _customPOIs.map((poi) {
                    return Marker(
                      point: poi.position,
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => _selectPOI(poi),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(int.parse(poi.categoryColor.replaceFirst('#', '0xFF'))).withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Color(int.parse(poi.categoryColor.replaceFirst('#', '0xFF'))),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              poi.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),

          // Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 80,
            right: 80,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Rechercher un bâtiment ou une salle...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _performSearch(''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Search Results
          if (_isSearching && (_filteredBuildings.isNotEmpty || _filteredRooms.isNotEmpty))
            Positioned(
              top: MediaQuery.of(context).padding.top + 76,
              left: 80,
              right: 80,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  children: [
                    if (_filteredBuildings.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Bâtiments (${_filteredBuildings.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ..._filteredBuildings.map((building) {
                        return ListTile(
                          leading: Icon(
                            _getBuildingIcon(building.type),
                            color: _getBuildingColor(building.type),
                          ),
                          title: Text(building.name),
                          subtitle: Text(building.typeLabel),
                          onTap: () => _selectBuilding(building),
                        );
                      }),
                    ],
                    if (_filteredRooms.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Salles (${_filteredRooms.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      ..._filteredRooms.map((room) {
                        return ListTile(
                          leading: Icon(
                            _getRoomIcon(room),
                            color: _getRoomColor(room),
                          ),
                          title: Text(room.name),
                          subtitle: Text('Salle ${room.roomNumber} • ${room.capacity} places • Étage ${room.floorNumber}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getRoomColor(room).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              room.occupancyStatus,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getRoomColor(room),
                              ),
                            ),
                          ),
                          onTap: () {
                            _performSearch(''); // Close search
                            _selectRoom(room);
                          },
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

          // POI Info Badge
          Positioned(
            bottom: _selectedBuilding != null ? 280 : 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.place,
                    color: _showPOIs ? const Color(0xFF48BB78) : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_customPOIs.length} POIs',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _showPOIs ? const Color(0xFF48BB78) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // POI Toggle Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: _showPOIs ? const Color(0xFF48BB78) : Colors.grey[300],
              onPressed: () {
                setState(() {
                  _showPOIs = !_showPOIs;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_showPOIs ? '✅ POIs affichés' : '❌ POIs masqués'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Icon(
                Icons.place,
                color: _showPOIs ? Colors.white : Colors.grey[700],
              ),
              heroTag: 'poi_toggle',
            ),
          ),

          // Refresh POIs Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 76,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () async {
                await _loadCustomPOIs();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🔄 ${_customPOIs.length} POIs rechargés'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: const Color(0xFF48BB78),
                    ),
                  );
                }
              },
              child: const Icon(Icons.refresh, color: Color(0xFF48BB78)),
              heroTag: 'poi_refresh',
            ),
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.black87),
              heroTag: 'back_button',
            ),
          ),

          // Building Info Panel with Rooms
          if (_selectedBuilding != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 260,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Building Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getBuildingColor(_selectedBuilding!.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getBuildingIcon(_selectedBuilding!.type),
                            color: _getBuildingColor(_selectedBuilding!.type),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedBuilding!.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _selectedBuilding!.typeLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getBuildingColor(_selectedBuilding!.type),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _selectedBuilding = null);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Rooms List Header
                    Row(
                      children: [
                        const Icon(Icons.meeting_room, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Salles disponibles (${_buildingRooms.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Rooms List
                    Expanded(
                      child: _buildingRooms.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.meeting_room_outlined, size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Aucune salle dans ce bâtiment',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _buildingRooms.length,
                              itemBuilder: (context, index) {
                                final room = _buildingRooms[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 1,
                                  child: ListTile(
                                    dense: true,
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _getRoomColor(room).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getRoomIcon(room),
                                        color: _getRoomColor(room),
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      room.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Salle ${room.roomNumber} • ${room.capacity} places • Étage ${room.floorNumber}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getRoomColor(room).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Réserver',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _getRoomColor(room),
                                        ),
                                      ),
                                    ),
                                    onTap: () => _selectRoom(room),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}