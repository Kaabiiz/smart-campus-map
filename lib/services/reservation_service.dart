import '../models/reservation.dart';
import '../models/room.dart';

class ReservationService {
  // Simulate backend storage
  static final List<Reservation> _reservations = [];

  // Get available time slots for a room on a specific date
  Future<List<TimeSlot>> getAvailableSlots(String roomId, DateTime date) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate time slots from 8:00 to 18:00
    final slots = <TimeSlot>[];
    final bookedSlots = _getBookedSlotsForRoom(roomId, date);

    for (int hour = 8; hour < 18; hour += 2) {
      final start = '${hour.toString().padLeft(2, '0')}:00';
      final end = '${(hour + 2).toString().padLeft(2, '0')}:00';
      final timeRange = '$start-$end';
      
      final isBooked = bookedSlots.contains(timeRange);
      
      slots.add(TimeSlot(
        start: start,
        end: end,
        isAvailable: !isBooked,
        reservedBy: isBooked ? 'Utilisateur' : null,
      ));
    }

    return slots;
  }

  // Reserve a room
  Future<bool> reserveRoom({
    required String roomId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String userId,
    required String userName,
    required String purpose,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Check if slot is available
    final timeRange = '$startTime-$endTime';
    final bookedSlots = _getBookedSlotsForRoom(roomId, date);
    
    if (bookedSlots.contains(timeRange)) {
      return false; // Slot already taken
    }

    // Create reservation
    final reservation = Reservation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: roomId,
      userId: userId,
      userName: userName,
      date: date,
      startTime: startTime,
      endTime: endTime,
      purpose: purpose,
      status: ReservationStatus.confirmed,
      createdAt: DateTime.now(),
    );

    _reservations.add(reservation);
    return true;
  }

  // Get user's reservations
  Future<List<Reservation>> getUserReservations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _reservations
        .where((r) => r.userId == userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Cancel reservation
  Future<bool> cancelReservation(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _reservations.indexWhere((r) => r.id == reservationId);
    
    if (index != -1) {
      _reservations[index] = Reservation(
        id: _reservations[index].id,
        roomId: _reservations[index].roomId,
        userId: _reservations[index].userId,
        userName: _reservations[index].userName,
        date: _reservations[index].date,
        startTime: _reservations[index].startTime,
        endTime: _reservations[index].endTime,
        purpose: _reservations[index].purpose,
        status: ReservationStatus.cancelled,
        createdAt: _reservations[index].createdAt,
      );
      return true;
    }
    return false;
  }

  // Helper: Get booked time slots for a room
  List<String> _getBookedSlotsForRoom(String roomId, DateTime date) {
    return _reservations
        .where((r) =>
            r.roomId == roomId &&
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day &&
            r.status != ReservationStatus.cancelled)
        .map((r) => '${r.startTime}-${r.endTime}')
        .toList();
  }
}