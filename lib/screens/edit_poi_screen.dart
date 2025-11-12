import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/poi.dart';
import '../services/poi_service.dart';

class EditPOIScreen extends StatefulWidget {
  final POI poi;

  const EditPOIScreen({
    Key? key,
    required this.poi,
  }) : super(key: key);

  @override
  State<EditPOIScreen> createState() => _EditPOIScreenState();
}

class _EditPOIScreenState extends State<EditPOIScreen> {
  final POIService _poiService = POIService();
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late POICategory _selectedCategory;
  late LatLng _selectedPosition;
  late String _selectedIcon;
  bool _isSaving = false;
  bool _isDeleting = false;

  final Map<POICategory, List<String>> _categoryIcons = {
    POICategory.parking: ['🅿️', '🚗', '🚙', '🏎️'],
    POICategory.entrance: ['🚪', '🚶', '➡️', '🏛️'],
    POICategory.exit: ['🚪', '⬅️', '🚶', '🔙'],
    POICategory.toilet: ['🚻', '🚽', '🧻', '💧'],
    POICategory.atm: ['🏧', '💳', '💰', '🏦'],
    POICategory.printer: ['🖨️', '📄', '🖶', '📋'],
    POICategory.wifi: ['📶', '📡', '🌐', '💻'],
    POICategory.cafeteria: ['🍕', '☕', '🍔', '🥪'],
    POICategory.study: ['📚', '📖', '✏️', '🎓'],
    POICategory.sports: ['⚽', '🏀', '🏐', '🎾'],
    POICategory.emergency: ['🚨', '🚑', '🆘', '⚠️'],
    POICategory.other: ['📍', '⭐', '🔵', '🟢'],
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.poi.name);
    _descriptionController = TextEditingController(text: widget.poi.description);
    _selectedCategory = widget.poi.category;
    _selectedPosition = widget.poi.position;
    _selectedIcon = widget.poi.icon;
  }

  Future<void> _updatePOI() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedPOI = widget.poi.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        position: _selectedPosition,
        icon: _selectedIcon,
      );

      final success = await _poiService.updatePOI(updatedPOI);

      setState(() => _isSaving = false);

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar('Erreur lors de la mise à jour');
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showErrorSnackBar('Erreur: $e');
    }
  }

  Future<void> _deletePOI() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le POI'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${widget.poi.name}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final success = await _poiService.deletePOI(widget.poi.id);

      if (success) {
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ POI supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() => _isDeleting = false);
        _showErrorSnackBar('Erreur lors de la suppression');
      }
    } catch (e) {
      setState(() => _isDeleting = false);
      _showErrorSnackBar('Erreur: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'POI mis à jour!',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Text(
          '✅ "${_nameController.text}" a été modifié avec succès!',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to list with refresh
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF48BB78),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text(
          'Modifier le POI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Delete button in AppBar
          if (!_isDeleting)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deletePOI,
              tooltip: 'Supprimer',
            ),
          if (_isDeleting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ID: ${widget.poi.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              _buildSectionTitle('Nom du POI'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ex: Parking principal',
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  if (value.trim().length < 3) {
                    return 'Le nom doit contenir au moins 3 caractères';
                  }
                  if (value.trim().length > 50) {
                    return 'Le nom ne doit pas dépasser 50 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description Field
              _buildSectionTitle('Description (optionnel)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ajoutez des détails sur ce POI...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.description),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value != null && value.length > 200) {
                    return 'La description ne doit pas dépasser 200 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category Selection
              _buildSectionTitle('Catégorie'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<POICategory>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      _getCategoryIcon(_selectedCategory),
                      color: _getCategoryColor(_selectedCategory),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: POICategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: 20,
                            color: _getCategoryColor(category),
                          ),
                          const SizedBox(width: 12),
                          Text(_getCategoryLabel(category)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      // Keep current icon if it exists in new category, otherwise use first
                      if (!_categoryIcons[value]!.contains(_selectedIcon)) {
                        _selectedIcon = _categoryIcons[value]!.first;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Icon Selection
              _buildSectionTitle('Icône'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _categoryIcons[_selectedCategory]!.map((icon) {
                    final isSelected = icon == _selectedIcon;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedIcon = icon);
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getCategoryColor(_selectedCategory).withOpacity(0.2)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? _getCategoryColor(_selectedCategory)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Map Selection
              _buildSectionTitle('Position sur la carte'),
              const SizedBox(height: 8),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedPosition,
                      initialZoom: 16,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedPosition = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.smart_campus_map',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPosition,
                            width: 60,
                            height: 60,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _selectedIcon,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Position: ${_selectedPosition.latitude.toStringAsFixed(5)}, ${_selectedPosition.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updatePOI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.update, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Mettre à jour le POI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Delete Button
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _isDeleting ? null : _deletePOI,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_forever, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Supprimer le POI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  String _getCategoryLabel(POICategory category) {
    switch (category) {
      case POICategory.parking: return 'Parking';
      case POICategory.entrance: return 'Entrée';
      case POICategory.exit: return 'Sortie';
      case POICategory.toilet: return 'Toilettes';
      case POICategory.atm: return 'ATM';
      case POICategory.printer: return 'Imprimante';
      case POICategory.wifi: return 'WiFi';
      case POICategory.cafeteria: return 'Cafétéria';
      case POICategory.study: return 'Étude';
      case POICategory.sports: return 'Sports';
      case POICategory.emergency: return 'Urgence';
      case POICategory.other: return 'Autre';
    }
  }

  IconData _getCategoryIcon(POICategory category) {
    switch (category) {
      case POICategory.parking: return Icons.local_parking;
      case POICategory.entrance: return Icons.login;
      case POICategory.exit: return Icons.logout;
      case POICategory.toilet: return Icons.wc;
      case POICategory.atm: return Icons.atm;
      case POICategory.printer: return Icons.print;
      case POICategory.wifi: return Icons.wifi;
      case POICategory.cafeteria: return Icons.restaurant;
      case POICategory.study: return Icons.menu_book;
      case POICategory.sports: return Icons.sports_soccer;
      case POICategory.emergency: return Icons.emergency;
      case POICategory.other: return Icons.place;
    }
  }

  Color _getCategoryColor(POICategory category) {
    final poi = POI(
      id: 'temp',
      name: 'temp',
      description: '',
      position: const LatLng(0, 0),
      category: category,
      icon: '',
    );
    return Color(int.parse(poi.categoryColor.replaceFirst('#', '0xFF')));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}