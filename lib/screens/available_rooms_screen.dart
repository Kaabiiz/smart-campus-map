import 'package:flutter/material.dart';
import '../models/room.dart';
import '../utils/mock_data.dart';
import 'room_reservation_screen.dart';

class AvailableRoomsScreen extends StatefulWidget {
  const AvailableRoomsScreen({Key? key}) : super(key: key);

  @override
  State<AvailableRoomsScreen> createState() => _AvailableRoomsScreenState();
}

class _AvailableRoomsScreenState extends State<AvailableRoomsScreen> {
  List<Room> _allRooms = [];
  List<Room> _filteredRooms = [];
  String _selectedFilter = 'all'; // all, available, occupied
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() {
    _allRooms = MockData.getRooms();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredRooms = _allRooms.where((room) {
        // Apply availability filter
        bool matchesFilter = true;
        if (_selectedFilter == 'available') {
          matchesFilter = room.isAvailable;
        } else if (_selectedFilter == 'occupied') {
          matchesFilter = !room.isAvailable;
        }

        // Apply search query
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          matchesSearch = room.name.toLowerCase().contains(query) ||
              room.roomNumber.toLowerCase().contains(query);
        }

        return matchesFilter && matchesSearch;
      }).toList();

      // Sort by occupancy (available first)
      _filteredRooms.sort((a, b) {
        if (a.isAvailable && !b.isAvailable) return -1;
        if (!a.isAvailable && b.isAvailable) return 1;
        return a.occupancyPercentage.compareTo(b.occupancyPercentage);
      });
    });
  }

  Color _getRoomColor(Room room) {
    if (!room.isAvailable) return Colors.grey;
    if (room.occupancyPercentage >= 80) return Colors.red;
    if (room.occupancyPercentage >= 50) return Colors.orange;
    return Colors.green;
  }

  IconData _getRoomIcon(Room room) {
    if (!room.isAvailable) return Icons.meeting_room_outlined;
    if (room.occupancyPercentage >= 80) return Icons.group;
    if (room.occupancyPercentage >= 50) return Icons.groups;
    return Icons.meeting_room;
  }

  @override
  Widget build(BuildContext context) {
    final availableCount = _allRooms.where((r) => r.isAvailable).length;
    final occupiedCount = _allRooms.length - availableCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text(
          'Salles Disponibles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF48BB78),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFF48BB78),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher une salle...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Stats Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Disponibles',
                    availableCount.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Occupées',
                    occupiedCount.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _allRooms.length.toString(),
                    Icons.meeting_room,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Toutes', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Disponibles', 'available'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Occupées', 'occupied'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Rooms List
          Expanded(
            child: _filteredRooms.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = _filteredRooms[index];
                      return _buildRoomCard(room);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
          _applyFilters();
        });
      },
      selectedColor: const Color(0xFF48BB78),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    final roomColor = _getRoomColor(room);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: room.isAvailable
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoomReservationScreen(room: room),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Room Icon with Occupancy
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: roomColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      _getRoomIcon(room),
                      color: roomColor,
                      size: 28,
                    ),
                    if (room.isAvailable)
                      Positioned(
                        bottom: 4,
                        child: Text(
                          '${room.occupancyPercentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: roomColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Room Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.door_front_door, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Salle ${room.roomNumber}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.layers, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Étage ${room.floorNumber}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.people, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${room.capacity} places',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (room.currentOccupation != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        room.currentOccupation!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: roomColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  room.isAvailable ? room.occupancyStatus : 'Occupée',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: roomColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune salle trouvée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}