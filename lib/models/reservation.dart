class Reservation {
  final String id;
  final String roomId;
  final String userId;
  final String userName;
  final String userEmail;        // ✅ ADD THIS FIELD
  final String roomName;         // ✅ ADD THIS FIELD
  final String buildingName;     // ✅ ADD THIS FIELD
  final DateTime date;
  final String startTime;
  final String endTime;
  final String purpose;
  final ReservationStatus status;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.userEmail,      // ✅ ADD THIS
    required this.roomName,       // ✅ ADD THIS
    required this.buildingName,   // ✅ ADD THIS
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    this.status = ReservationStatus.pending,
    required this.createdAt,
  });

  // ✅ ADD: Get time slot as TimeSlot object
  TimeSlot get timeSlot {
    return TimeSlot(
      start: startTime,
      end: endTime,
      isAvailable: true,
    );
  }

  // ✅ ADD: Helper method to get formatted date
  String get formattedDate {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ✅ ADD: Helper method to check if reservation is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // ✅ ADD: Helper method to check if reservation is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }

  // ✅ ADD: Get relative date string (Today, Tomorrow, or date)
  String get relativeDateString {
    if (isToday) return 'Aujourd\'hui';
    if (isTomorrow) return 'Demain';
    return formattedDate;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,        // ✅ ADD THIS
      'roomName': roomName,          // ✅ ADD THIS
      'buildingName': buildingName,  // ✅ ADD THIS
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'purpose': purpose,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      roomId: json['roomId'],
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'] ?? '',        // ✅ ADD THIS
      roomName: json['roomName'] ?? '',          // ✅ ADD THIS
      buildingName: json['buildingName'] ?? '',  // ✅ ADD THIS
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      purpose: json['purpose'],
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReservationStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

class TimeSlot {
  final String start;
  final String end;
  final bool isAvailable;
  final String? reservedBy;

  TimeSlot({
    required this.start,
    required this.end,
    required this.isAvailable,
    this.reservedBy,
  });

  String get displayTime => '$start - $end';
  
  // ✅ ADD: toString for compatibility
  @override
  String toString() => '$start - $end';
}