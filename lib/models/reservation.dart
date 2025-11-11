class Reservation {
  final String id;
  final String roomId;
  final String userId;
  final String userName;
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
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    this.status = ReservationStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
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
}