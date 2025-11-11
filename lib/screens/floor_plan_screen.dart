import 'package:flutter/material.dart';
import '../models/building.dart';
import '../models/floor_plan.dart';
import '../models/room.dart';
import '../utils/mock_data.dart';
import '../utils/constants.dart';
import 'room_reservation_screen.dart';

class FloorPlanScreen extends StatefulWidget {
  final Building building;

  const FloorPlanScreen({Key? key, required this.building}) : super(key: key);

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends State<FloorPlanScreen> {
  int _selectedFloor = 0;
  String? _selectedRoomId;

  @override
  Widget build(BuildContext context) {
    final floorPlans = MockData.getFloorPlans(widget.building.id);
    final rooms = MockData.getRoomsByBuildingId(widget.building.id);
    final floorRooms = rooms.where((r) => r.floorNumber == _selectedFloor).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Plan intérieur - ${widget.building.name}'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Floor selector
          if (widget.building.numberOfFloors > 1)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sélectionner un étage',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
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
                                setState(() {
                                  _selectedFloor = index;
                                  _selectedRoomId = null;
                                });
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
              ),
            ),

          // Floor plan view
          Expanded(
            child: floorPlans.isEmpty
                ? _buildNoFloorPlanMessage()
                : _buildFloorPlanView(floorPlans, floorRooms),
          ),

          // Room list at bottom
          if (floorRooms.isNotEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                itemCount: floorRooms.length,
                itemBuilder: (context, index) {
                  final room = floorRooms[index];
                  final isSelected = _selectedRoomId == room.id;
                  return _buildRoomMiniCard(room, isSelected);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoFloorPlanMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Plan intérieur non disponible',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette fonctionnalité sera bientôt disponible',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorPlanView(List<FloorPlan> floorPlans, List<Room> rooms) {
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 4.0,
      child: Container(
        color: Colors.grey[100],
        child: Center(
          child: CustomPaint(
            size: const Size(400, 400),
            painter: FloorPlanPainter(
              floorPlans: floorPlans,
              selectedFloor: _selectedFloor,
              rooms: rooms,
              selectedRoomId: _selectedRoomId,
              onRoomTap: (roomId) {
                setState(() => _selectedRoomId = roomId);
                final room = rooms.firstWhere((r) => r.id == roomId);
                _showRoomDetails(room);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomMiniCard(Room room, bool isSelected) {
    final occupancyPercentage = room.occupancyPercentage;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedRoomId = room.id);
        _showRoomDetails(room);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _getOccupancyColor(occupancyPercentage).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${occupancyPercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: _getOccupancyColor(occupancyPercentage),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    room.roomNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              room.name,
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.people, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${room.currentOccupancy}/${room.capacity}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: room.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    room.isAvailable ? 'Libre' : 'Occupé',
                    style: TextStyle(
                      fontSize: 9,
                      color: room.isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomDetails(Room room) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getOccupancyColor(room.occupancyPercentage).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${room.occupancyPercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getOccupancyColor(room.occupancyPercentage),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${room.currentOccupancy}/${room.capacity} personnes • ${room.occupancyStatus}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (room.currentOccupation != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        room.currentOccupation!,
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomReservationScreen(room: room),
                    ),
                  );
                },
                icon: const Icon(Icons.event),
                label: const Text('Réserver cette salle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getOccupancyColor(double percentage) {
    if (percentage < 50) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
  }
}

// Custom painter for floor plan
class FloorPlanPainter extends CustomPainter {
  final List<FloorPlan> floorPlans;
  final int selectedFloor;
  final List<Room> rooms;
  final String? selectedRoomId;
  final Function(String) onRoomTap;

  FloorPlanPainter({
    required this.floorPlans,
    required this.selectedFloor,
    required this.rooms,
    this.selectedRoomId,
    required this.onRoomTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // Find floor plan for selected floor
    final floorPlan = floorPlans.firstWhere(
      (fp) => fp.floorNumber == selectedFloor,
      orElse: () => floorPlans.first,
    );

    // Draw building outline
    final outlinePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(
      Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
      outlinePaint,
    );

    // Draw each room
    for (var roomPolygon in floorPlan.roomPolygons) {
      final room = rooms.firstWhere(
        (r) => r.id == roomPolygon.roomId,
        orElse: () => rooms.first,
      );

      final isSelected = selectedRoomId == room.id;
      final occupancyPercentage = room.occupancyPercentage;

      // Room fill color based on occupancy
      paint.color = _getRoomColor(occupancyPercentage, isSelected);

      // Draw room polygon
      final path = Path();
      path.moveTo(roomPolygon.coordinates.first.dx, roomPolygon.coordinates.first.dy);
      for (var coord in roomPolygon.coordinates.skip(1)) {
        path.lineTo(coord.dx, coord.dy);
      }
      path.close();

      canvas.drawPath(path, paint);

      // Draw room border
      final borderPaint = Paint()
        ..color = isSelected ? AppConstants.primaryColor : Colors.grey[700]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3 : 1.5;

      canvas.drawPath(path, borderPaint);

      // Draw room number
      final textPainter = TextPainter(
        text: TextSpan(
          text: roomPolygon.roomNumber,
          style: TextStyle(
            color: isSelected ? AppConstants.primaryColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: isSelected ? 16 : 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          roomPolygon.center.dx - textPainter.width / 2,
          roomPolygon.center.dy - textPainter.height / 2,
        ),
      );

      // Draw occupancy percentage
      final occupancyPainter = TextPainter(
        text: TextSpan(
          text: '${occupancyPercentage.toInt()}%',
          style: TextStyle(
            color: _getOccupancyColor(occupancyPercentage),
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      occupancyPainter.layout();
      occupancyPainter.paint(
        canvas,
        Offset(
          roomPolygon.center.dx - occupancyPainter.width / 2,
          roomPolygon.center.dy + textPainter.height / 2 + 4,
        ),
      );
    }
  }

  Color _getRoomColor(double occupancyPercentage, bool isSelected) {
    if (isSelected) {
      return AppConstants.primaryColor.withOpacity(0.3);
    }
    if (occupancyPercentage < 50) return Colors.green.withOpacity(0.2);
    if (occupancyPercentage < 80) return Colors.orange.withOpacity(0.2);
    return Colors.red.withOpacity(0.2);
  }

  Color _getOccupancyColor(double percentage) {
    if (percentage < 50) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant FloorPlanPainter oldDelegate) {
    return oldDelegate.selectedFloor != selectedFloor ||
        oldDelegate.selectedRoomId != selectedRoomId;
  }
}