import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/poi.dart';
import '../services/poi_service.dart';
import '../utils/mock_data.dart';

class AddPOIScreen extends StatefulWidget {
  const AddPOIScreen({Key? key}) : super(key: key);

  @override
  State<AddPOIScreen> createState() => _AddPOIScreenState();
}

class _AddPOIScreenState extends State<AddPOIScreen> {
  final POIService _poiService = POIService();
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();

  // Form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  POICategory _selectedCategory = POICategory.other;
  LatLng _selectedPosition = MockData.campusCenter;
  bool _isLocationSelected = false;
  bool _isSaving = false;

  // Available icons for each category
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

  String _selectedIcon = '📍';

  @override
  void initState() {
    super.initState();
    _selectedIcon = _categoryIcons[_selectedCategory]!.first;
  }

  Future<void> _savePOI() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isLocationSelected) {
      _showErrorSnackBar('Veuillez sélectionner une position sur la carte');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final success = await _poiService.createPOI(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        position: _selectedPosition,
        category: _selectedCategory,
        customIcon: _selectedIcon,
      );

      setState(() => _isSaving = false);

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar('Erreur lors de la création du POI');
      }
    } catch (e) {
      setState(() => _isSaving = false);
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
                'POI créé!',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: Text(
          '✅ "${_nameController.text}" a été ajouté avec succès!',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to list with refresh
            },
            child: const Text('Terminer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _resetForm(); // Reset form for another POI
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF48BB78),
            ),
            child: const Text('Ajouter un autre'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = POICategory.other;
      _selectedPosition = MockData.campusCenter;
      _isLocationSelected = false;
      _selectedIcon = _categoryIcons[_selectedCategory]!.first;
    });
    _mapController.move(_selectedPosition, 16);
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
          'Ajouter un POI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF48BB78),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      _selectedIcon = _categoryIcons[value]!.first;
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
                          _isLocationSelected = true;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.smart_campus_map',
                      ),
                      if (_isLocationSelected)
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
              if (_isLocationSelected) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Position: ${_selectedPosition.latitude.toStringAsFixed(5)}, ${_selectedPosition.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tapez sur la carte pour sélectionner une position',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePOI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48BB78),
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
                            Icon(Icons.save, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Enregistrer le POI',
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
      case POICategory.parking:
        return 'Parking';
      case POICategory.entrance:
        return 'Entrée';
      case POICategory.exit:
        return 'Sortie';
      case POICategory.toilet:
        return 'Toilettes';
      case POICategory.atm:
        return 'ATM';
      case POICategory.printer:
        return 'Imprimante';
      case POICategory.wifi:
        return 'WiFi';
      case POICategory.cafeteria:
        return 'Cafétéria';
      case POICategory.study:
        return 'Étude';
      case POICategory.sports:
        return 'Sports';
      case POICategory.emergency:
        return 'Urgence';
      case POICategory.other:
        return 'Autre';
    }
  }

  IconData _getCategoryIcon(POICategory category) {
    switch (category) {
      case POICategory.parking:
        return Icons.local_parking;
      case POICategory.entrance:
        return Icons.login;
      case POICategory.exit:
        return Icons.logout;
      case POICategory.toilet:
        return Icons.wc;
      case POICategory.atm:
        return Icons.atm;
      case POICategory.printer:
        return Icons.print;
      case POICategory.wifi:
        return Icons.wifi;
      case POICategory.cafeteria:
        return Icons.restaurant;
      case POICategory.study:
        return Icons.menu_book;
      case POICategory.sports:
        return Icons.sports_soccer;
      case POICategory.emergency:
        return Icons.emergency;
      case POICategory.other:
        return Icons.place;
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