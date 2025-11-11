import 'package:flutter/material.dart';
import '../models/building.dart';
import '../models/room.dart';
import '../models/floor_plan.dart';
import '../utils/mock_data.dart';
import '../utils/constants.dart';
import 'room_reservation_screen.dart';
import 'floor_plan_screen.dart';

class BuildingDetailScreen extends StatefulWidget {
  final Building building;

  const BuildingDetailScreen({Key? key, required this.building}) : super(key: key);

  @override
  State<BuildingDetailScreen> createState() => _BuildingDetailScreenState();
}

class _BuildingDetailScreenState extends State<BuildingDetailScreen> {
  int _selectedFloor = 0; // NEW: Track selected floor

  @override
  Widget build(BuildContext context) {
    final rooms = MockData.getRoomsByBuildingId(widget.building.id);
    // NEW: Filter rooms by selected floor
    final floorRooms = rooms.where((r) => r.floorNumber == _selectedFloor).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.building.name),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // NEW: Indoor map button
          if (widget.building.hasIndoorMap)
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: 'Voir plan intérieur',
              onPressed: () => _openIndoorMap(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Building image
            if (widget.building.imageUrl != null)
              Image.network(
                widget.building.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 200,
                color: AppConstants.buildingColors[widget.building.type.name] ?? Colors.blue,
                child: Center(
                  child: Icon(
                    _getBuildingIcon(widget.building.type),
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            
            // Building info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppConstants.buildingColors[widget.building.type.name]?.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.building.typeLabel,
                          style: TextStyle(
                            color: AppConstants.buildingColors[widget.building.type.name],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // NEW: Status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.building.isOpen ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.building.isOpen ? Icons.lock_open : Icons.lock,
                              size: 14,
                              color: widget.building.isOpen ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.building.isOpen ? 'Ouvert' : 'Fermé',
                              style: TextStyle(
                                color: widget.building.isOpen ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.building.description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  
                  // NEW: Building stats
                  _buildStatsRow(rooms),
                  
                  const SizedBox(height: 24),
                  
                  // NEW: Floor selector (only if building has multiple floors)
                  if (widget.building.numberOfFloors > 1)
                    _buildFloorSelector(),
                  
                  const SizedBox(height: 16),
                  
                  // Rooms header with floor info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.building.numberOfFloors > 1
                            ? 'Salles - Étage $_selectedFloor'
                            : 'Salles disponibles',
                        style: AppConstants.titleStyle,
                      ),
                      Text(
                        '${floorRooms.length} salle${floorRooms.length > 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Rooms list
            if (floorRooms.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'Aucune salle sur cet étage',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...floorRooms.map((room) => _buildRoomCard(context, room)),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // NEW: Build stats row showing room count, capacity, and occupancy
  Widget _buildStatsRow(List<Room> rooms) {
    final totalCapacity = rooms.fold<int>(0, (sum, room) => sum + room.capacity);
    final totalOccupancy = rooms.fold<int>(0, (sum, room) => sum + room.currentOccupancy);
    final avgOccupancy = totalCapacity > 0 ? (totalOccupancy / totalCapacity * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.meeting_room,
            '${rooms.length}',
            'Salles',
            Colors.blue,
          ),
          _buildStatItem(
            Icons.people,
            '$totalCapacity',
            'Capacité',
            Colors.green,
          ),
          _buildStatItem(
            Icons.event_seat,
            '$avgOccupancy%',
            'Occupation',
            _getOccupancyColor(avgOccupancy.toDouble()),
          ),
          if (widget.building.numberOfFloors > 1)
            _buildStatItem(
              Icons.layers,
              '${widget.building.numberOfFloors}',
              'Étages',
              Colors.orange,
            ),
        ],
      ),
    );
  }

  // NEW: Build individual stat item
  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // NEW: Floor selector widget
  Widget _buildFloorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélectionner un étage',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.building.numberOfFloors,
            itemBuilder: (context, index) {
              final isSelected = _selectedFloor == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('Étage $index'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFloor = index);
                    }
                  },
                  selectedColor: AppConstants.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // UPDATED: Room card with occupancy visualization
  Widget _buildRoomCard(BuildContext context, Room room) {
    final occupancyPercentage = room.occupancyPercentage;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openReservationScreen(room),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // NEW: Occupancy indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: occupancyPercentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getOccupancyColor(occupancyPercentage),
                          ),
                          strokeWidth: 5,
                        ),
                      ),
                      Text(
                        '${occupancyPercentage.toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getOccupancyColor(occupancyPercentage),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              room.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: room.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                room.isAvailable ? 'Libre' : 'Occupée',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: room.isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // NEW: Occupancy info
                        Text(
                          '${room.currentOccupancy}/${room.capacity} personnes • ${room.occupancyStatus}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (room.currentOccupation != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              room.currentOccupation!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              if (room.equipment.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: room.equipment.map((eq) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getEquipmentIcon(eq), size: 12, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text(
                            eq,
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // NEW: Get color based on occupancy percentage
  Color _getOccupancyColor(double percentage) {
    if (percentage < 50) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
  }

  // NEW: Get icon for equipment
  IconData _getEquipmentIcon(String equipment) {
    final lower = equipment.toLowerCase();
    if (lower.contains('projecteur') || lower.contains('vidéo')) return Icons.videocam;
    if (lower.contains('micro')) return Icons.mic;
    if (lower.contains('tableau')) return Icons.dashboard;
    if (lower.contains('wifi')) return Icons.wifi;
    if (lower.contains('pc') || lower.contains('ordinateur')) return Icons.computer;
    return Icons.check_circle;
  }

  // NEW: Open indoor map screen
  void _openIndoorMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FloorPlanScreen(building: widget.building),
      ),
    );
  }

  // UPDATED: Open reservation screen instead of dialog
  void _openReservationScreen(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomReservationScreen(room: room),
      ),
    );
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
}