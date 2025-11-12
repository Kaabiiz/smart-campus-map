import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:latlong2/latlong.dart';  // ✅ ADD THIS IMPORT
import '../models/reservation.dart';
import '../models/poi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smart_campus.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Reservations Table
    await db.execute('''
      CREATE TABLE reservations (
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_email TEXT NOT NULL,
        room_name TEXT NOT NULL,
        building_name TEXT NOT NULL,
        date TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        purpose TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create POIs (Points of Interest) Table
    await db.execute('''
      CREATE TABLE pois (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        category TEXT NOT NULL,
        icon TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    print('✅ Database tables created successfully!');
  }

  // ==================== RESERVATION CRUD ====================

  // CREATE: Insert new reservation
  Future<int> insertReservation(Reservation reservation) async {
    final db = await database;
    return await db.insert(
      'reservations',
      {
        'id': reservation.id,
        'room_id': reservation.roomId,
        'user_id': reservation.userId,
        'user_name': reservation.userName,
        'user_email': reservation.userEmail,
        'room_name': reservation.roomName,
        'building_name': reservation.buildingName,
        'date': reservation.date.toIso8601String(),
        'start_time': reservation.startTime,  // ✅ FIXED
        'end_time': reservation.endTime,      // ✅ FIXED
        'purpose': reservation.purpose,
        'status': reservation.status.toString().split('.').last,
        'created_at': reservation.createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ: Get all reservations
  Future<List<Reservation>> getAllReservations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return _reservationFromMap(maps[i]);
    });
  }

  // READ: Get upcoming reservations (future dates only)
  Future<List<Reservation>> getUpcomingReservations() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      where: 'date >= ? AND status = ?',
      whereArgs: [now, 'confirmed'],
      orderBy: 'date ASC',
      limit: 5,
    );

    return List.generate(maps.length, (i) {
      return _reservationFromMap(maps[i]);
    });
  }

  // READ: Get reservation by ID
  Future<Reservation?> getReservationById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _reservationFromMap(maps.first);
  }

  // UPDATE: Update reservation status
  Future<int> updateReservationStatus(String id, ReservationStatus status) async {
    final db = await database;
    return await db.update(
      'reservations',
      {'status': status.toString().split('.').last},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE: Delete reservation
  Future<int> deleteReservation(String id) async {
    final db = await database;
    return await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // COUNT: Get total reservations count
  Future<int> getReservationsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM reservations');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== POI CRUD ====================

  // CREATE: Insert new POI
  Future<int> insertPoi(POI poi) async {
    final db = await database;
    return await db.insert(
      'pois',
      {
        'id': poi.id,
        'name': poi.name,
        'description': poi.description,
        'latitude': poi.position.latitude,
        'longitude': poi.position.longitude,
        'category': poi.category.toString().split('.').last,
        'icon': poi.icon,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ: Get all POIs
  Future<List<POI>> getAllPois() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pois');

    return List.generate(maps.length, (i) {
      return _poiFromMap(maps[i]);
    });
  }

  // READ: Get POI by ID
  Future<POI?> getPoiById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pois',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _poiFromMap(maps.first);
  }

  // UPDATE: Update POI
  Future<int> updatePoi(POI poi) async {
    final db = await database;
    return await db.update(
      'pois',
      {
        'name': poi.name,
        'description': poi.description,
        'latitude': poi.position.latitude,
        'longitude': poi.position.longitude,
        'category': poi.category.toString().split('.').last,
        'icon': poi.icon,
      },
      where: 'id = ?',
      whereArgs: [poi.id],
    );
  }

  // DELETE: Delete POI
  Future<int> deletePoi(String id) async {
    final db = await database;
    return await db.delete(
      'pois',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // COUNT: Get total POIs count
  Future<int> getPoisCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM pois');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== HELPER METHODS ====================

  // ✅ FIXED: Changed to use startTime/endTime instead of timeSlot
  Reservation _reservationFromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      roomId: map['room_id'],
      userId: map['user_id'],
      userName: map['user_name'],
      userEmail: map['user_email'],
      roomName: map['room_name'],
      buildingName: map['building_name'],
      date: DateTime.parse(map['date']),
      startTime: map['start_time'],      // ✅ FIXED
      endTime: map['end_time'],          // ✅ FIXED
      purpose: map['purpose'],
      status: ReservationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // ✅ FIXED: Added LatLng import at top
  POI _poiFromMap(Map<String, dynamic> map) {
    return POI(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      position: LatLng(map['latitude'], map['longitude']),
      category: POICategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
      ),
      icon: map['icon'],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}