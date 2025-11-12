import '../models/reservation.dart';
import '../models/room.dart';
import 'database_helper.dart';

class ReservationService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get available time slots for a room on a specific date
  Future<List<TimeSlot>> getAvailableSlots(String roomId, DateTime date) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate time slots from 8:00 to 18:00
    final slots = <TimeSlot>[];
    final bookedSlots = await _getBookedSlotsForRoom(roomId, date);

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

  // Reserve a room (with SQLite storage)
  Future<bool> reserveRoom({
    required String roomId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String userId,
    required String userName,
    required String userEmail,      // ✅ NEW REQUIRED PARAM
    required String roomName,       // ✅ NEW REQUIRED PARAM
    required String buildingName,   // ✅ NEW REQUIRED PARAM
    required String purpose,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Check if slot is available
    final timeRange = '$startTime-$endTime';
    final bookedSlots = await _getBookedSlotsForRoom(roomId, date);
    
    if (bookedSlots.contains(timeRange)) {
      return false; // Slot already taken
    }

    // Create reservation
    final reservation = Reservation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: roomId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,          // ✅ NEW
      roomName: roomName,            // ✅ NEW
      buildingName: buildingName,    // ✅ NEW
      date: date,
      startTime: startTime,
      endTime: endTime,
      purpose: purpose,
      status: ReservationStatus.confirmed,
      createdAt: DateTime.now(),
    );

    // ✅ Save to SQLite database
    try {
      await _dbHelper.insertReservation(reservation);
      print('✅ Reservation saved to database: ${reservation.id}');
      return true;
    } catch (e) {
      print('❌ Error saving reservation: $e');
      return false;
    }
  }

  // Get user's reservations (from SQLite)
  Future<List<Reservation>> getUserReservations(String userId) async {
    try {
      final allReservations = await _dbHelper.getAllReservations();
      return allReservations
          .where((r) => r.userId == userId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      print('❌ Error getting user reservations: $e');
      return [];
    }
  }

  // Get upcoming reservations (from SQLite)
  Future<List<Reservation>> getUpcomingReservations() async {
    try {
      return await _dbHelper.getUpcomingReservations();
    } catch (e) {
      print('❌ Error getting upcoming reservations: $e');
      return [];
    }
  }

  // Get all reservations (from SQLite)
  Future<List<Reservation>> getAllReservations() async {
    try {
      return await _dbHelper.getAllReservations();
    } catch (e) {
      print('❌ Error getting all reservations: $e');
      return [];
    }
  }

  // Get reservations count (from SQLite)
  Future<int> getReservationsCount() async {
    try {
      return await _dbHelper.getReservationsCount();
    } catch (e) {
      print('❌ Error getting reservations count: $e');
      return 0;
    }
  }

  // Cancel reservation (update in SQLite)
  Future<bool> cancelReservation(String reservationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final result = await _dbHelper.updateReservationStatus(
        reservationId, 
        ReservationStatus.cancelled,
      );
      
      if (result > 0) {
        print('✅ Reservation cancelled: $reservationId');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error cancelling reservation: $e');
      return false;
    }
  }

  // Delete reservation (remove from SQLite)
  Future<bool> deleteReservation(String reservationId) async {
    try {
      final result = await _dbHelper.deleteReservation(reservationId);
      
      if (result > 0) {
        print('✅ Reservation deleted: $reservationId');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting reservation: $e');
      return false;
    }
  }

  // Helper: Get booked time slots for a room (from SQLite)
  Future<List<String>> _getBookedSlotsForRoom(String roomId, DateTime date) async {
    try {
      final allReservations = await _dbHelper.getAllReservations();
      
      return allReservations
          .where((r) =>
              r.roomId == roomId &&
              r.date.year == date.year &&
              r.date.month == date.month &&
              r.date.day == date.day &&
              r.status != ReservationStatus.cancelled)
          .map((r) => '${r.startTime}-${r.endTime}')
          .toList();
    } catch (e) {
      print('❌ Error getting booked slots: $e');
      return [];
    }
  }
}