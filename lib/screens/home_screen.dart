import 'package:flutter/material.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/reservation_card_widget.dart';
import '../widgets/home_banner_widget.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../services/database_helper.dart';
import '../utils/mock_data.dart';  // ✅ FIXED: Changed from ../data/ to ../utils/
import 'map_screen.dart';
import 'poi_list_screen.dart';
import 'my_reservations_screen.dart';      // ✅ ADD THIS LINE
import 'available_rooms_screen.dart';      // ✅ ADD THIS LINE


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReservationService _reservationService = ReservationService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<Reservation> _upcomingReservations = [];
  int _reservationsCount = 0;
  int _poisCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final reservations = await _reservationService.getUpcomingReservations();
      final reservationsCount = await _dbHelper.getReservationsCount();
      final poisCount = await _dbHelper.getPoisCount();

      setState(() {
        _upcomingReservations = reservations.take(3).toList();
        _reservationsCount = reservationsCount;
        _poisCount = poisCount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelReservation(String reservationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _reservationService.cancelReservation(reservationId);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Réservation annulée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erreur lors de l\'annulation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text(
          'Smart Campus Map',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Show profile
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeBanner(userName: 'Ahmed Kaabi'),
                    const SizedBox(height: 24),

                    const Text(
                      'Statistiques',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 16),
Row(
  children: [
    Expanded(
      child: StatCard(
        value: _reservationsCount.toString(),
        label: 'Mes\nRéservations',
        icon: Icons.calendar_today,
        color: const Color(0xFF667EEA),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyReservationsScreen(),  // ❌ REMOVE const
            ),
          );
        },
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: StatCard(
        value: MockData.getRooms().length.toString(),
        label: 'Salles\nDisponibles',
        icon: Icons.meeting_room,
        color: const Color(0xFF48BB78),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AvailableRoomsScreen(),  // ❌ REMOVE const
            ),
          );
        },
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: StatCard(
        value: _poisCount.toString(),
        label: 'Points\nd\'intérêt',
        icon: Icons.place,
        color: const Color(0xFFED8936),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const POIListScreen(),  // ✅ This one can stay const
            ),
          );
        },
      ),
    ),
  ],
),
                    const SizedBox(height: 32),

                    _buildActionButton(
                      icon: Icons.map,
                      title: 'Carte Interactive',
                      subtitle: 'Explorer le campus en 3D',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.add_location_alt,
                      title: 'Gérer les Points d\'Intérêt',
                      subtitle: 'Ajouter ou modifier des POIs',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF48BB78), Color(0xFF38A169)],
                      ),
                      onTap: () {
                        // ✅ UPDATED: Navigate to POI List Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const POIListScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '📅 Prochaines Réservations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        if (_upcomingReservations.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              // TODO: Navigate to all reservations
                            },
                            child: const Text('Voir tout'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_upcomingReservations.isEmpty)
                      _buildEmptyState()
                    else
                      ..._upcomingReservations.map(
                        (reservation) => ReservationCard(
                          reservation: reservation,
                          onCancel: () => _cancelReservation(reservation.id),
                          onView: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Réservation #${reservation.id}'),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune réservation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par explorer la carte\net réserver une salle!',
            textAlign: TextAlign.center,
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