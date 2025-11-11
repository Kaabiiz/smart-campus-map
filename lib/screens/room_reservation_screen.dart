import 'package:flutter/material.dart';
import '../models/room.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';
import '../utils/constants.dart';

class RoomReservationScreen extends StatefulWidget {
  final Room room;

  const RoomReservationScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<RoomReservationScreen> createState() => _RoomReservationScreenState();
}

class _RoomReservationScreenState extends State<RoomReservationScreen> {
  final ReservationService _reservationService = ReservationService();
  final TextEditingController _purposeController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedTimeSlot;
  List<TimeSlot> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableSlots();
  }

  Future<void> _loadAvailableSlots() async {
    setState(() => _isLoading = true);
    try {
      final slots = await _reservationService.getAvailableSlots(
        widget.room.id,
        _selectedDate,
      );
      setState(() {
        _availableSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors du chargement des créneaux');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null;
      });
      _loadAvailableSlots();
    }
  }

  Future<void> _makeReservation() async {
    if (_selectedTimeSlot == null) {
      _showErrorSnackBar('Veuillez sélectionner un créneau horaire');
      return;
    }

    if (_purposeController.text.trim().isEmpty) {
      _showErrorSnackBar('Veuillez indiquer le motif de réservation');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _reservationService.reserveRoom(
        roomId: widget.room.id,
        date: _selectedDate,
        startTime: _selectedTimeSlot!.start,
        endTime: _selectedTimeSlot!.end,
        userId: 'user_123', // TODO: Get from authentication
        userName: 'Utilisateur Test',
        purpose: _purposeController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar('Ce créneau est déjà réservé');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors de la réservation');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 32),
            ),
            const SizedBox(width: 12),
            const Text('Réservation confirmée'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Votre réservation a été effectuée avec succès !'),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.meeting_room, widget.room.name),
            _buildInfoRow(Icons.calendar_today, _formatDate(_selectedDate)),
            _buildInfoRow(Icons.access_time, _selectedTimeSlot!.displayTime),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final occupancyPercentage = widget.room.occupancyPercentage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver une salle'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room info card
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Occupancy indicator
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: occupancyPercentage / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getOccupancyColor(occupancyPercentage),
                                ),
                                strokeWidth: 6,
                              ),
                              Text(
                                '${occupancyPercentage.toInt()}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getOccupancyColor(occupancyPercentage),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.room.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Capacité: ${widget.room.capacity} personnes',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (widget.room.currentOccupation != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    widget.room.currentOccupation!,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Date selection
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sélectionner une date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: AppConstants.primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _formatDate(_selectedDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Time slots
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Créneaux disponibles',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_availableSlots.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Aucun créneau disponible',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableSlots.map((slot) {
                              final isSelected = _selectedTimeSlot == slot;
                              return _buildTimeSlotChip(slot, isSelected);
                            }).toList(),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Purpose input
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Motif de réservation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _purposeController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Ex: Réunion de projet, Cours particulier...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppConstants.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reserve button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedTimeSlot != null && !_isLoading
                            ? _makeReservation
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: const Text(
                          'Confirmer la réservation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeSlotChip(TimeSlot slot, bool isSelected) {
    final isAvailable = slot.isAvailable;

    return ChoiceChip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            slot.displayTime,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : isAvailable
                      ? Colors.black87
                      : Colors.grey,
            ),
          ),
          if (!isAvailable)
            Text(
              'Réservé',
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.red,
              ),
            ),
        ],
      ),
      selected: isSelected,
      onSelected: isAvailable
          ? (selected) {
              setState(() => _selectedTimeSlot = selected ? slot : null);
            }
          : null,
      selectedColor: AppConstants.primaryColor,
      backgroundColor: isAvailable ? Colors.white : Colors.grey[200],
      disabledColor: Colors.grey[200],
      side: BorderSide(
        color: isAvailable
            ? (isSelected ? AppConstants.primaryColor : Colors.grey[300]!)
            : Colors.grey[400]!,
      ),
    );
  }

  Color _getOccupancyColor(double percentage) {
    if (percentage < 50) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }
}