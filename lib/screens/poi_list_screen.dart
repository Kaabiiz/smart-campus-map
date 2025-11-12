import 'package:flutter/material.dart';
import '../models/poi.dart';
import '../services/poi_service.dart';
import '../widgets/poi_card_widget.dart';
import 'add_poi_screen.dart';
import 'edit_poi_screen.dart';

class POIListScreen extends StatefulWidget {
  const POIListScreen({Key? key}) : super(key: key);

  @override
  State<POIListScreen> createState() => _POIListScreenState();
}

class _POIListScreenState extends State<POIListScreen> {
  final POIService _poiService = POIService();
  List<POI> _allPois = [];
  List<POI> _filteredPois = [];
  POICategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPOIs();
  }

  Future<void> _loadPOIs() async {
    setState(() => _isLoading = true);

    try {
      final pois = await _poiService.getAllPOIs();
      setState(() {
        _allPois = pois;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors du chargement des POIs');
    }
  }

  void _applyFilters() {
    _filteredPois = _allPois.where((poi) {
      // Category filter
      if (_selectedCategory != null && poi.category != _selectedCategory) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return poi.name.toLowerCase().contains(query) ||
               poi.description.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  Future<void> _deletePOI(POI poi) async {
    final success = await _poiService.deletePOI(poi.id);

    if (success) {
      _showSuccessSnackBar('POI supprimé avec succès');
      _loadPOIs();
    } else {
      _showErrorSnackBar('Erreur lors de la suppression');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text(
          'Points d\'Intérêt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF48BB78),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Statistics
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_filteredPois.length} POIs',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFF48BB78),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un POI...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Category Filter Chips
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFilterChip('Tous', null, Icons.all_inclusive),
                const SizedBox(width: 8),
                ...POICategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      _getCategoryLabel(category),
                      category,
                      _getCategoryIcon(category),
                    ),
                  );
                }),
              ],
            ),
          ),

          // POI List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPois.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadPOIs,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPois.length,
                          itemBuilder: (context, index) {
                            final poi = _filteredPois[index];
                            return POICardWidget(
                              poi: poi,
                              onTap: () {
                                // TODO: Navigate to POI detail or show on map
                                _showSuccessSnackBar('Afficher ${poi.name} sur la carte');
                              },
                              onEdit: () async {
                                // ✅ UPDATED: Navigate to Edit POI screen
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditPOIScreen(poi: poi),
                                  ),
                                );
                                
                                // Reload if POI was updated or deleted
                                if (result == true) {
                                  _loadPOIs();
                                }
                              },
                              onDelete: () => _deletePOI(poi),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // ✅ Navigate to Add POI screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPOIScreen(),
            ),
          );
          
          // Reload POIs if a new POI was added
          if (result == true) {
            _loadPOIs();
          }
        },
        backgroundColor: const Color(0xFF48BB78),
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Ajouter POI'),
      ),
    );
  }

  Widget _buildFilterChip(String label, POICategory? category, IconData icon) {
    final isSelected = _selectedCategory == category;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : const Color(0xFF48BB78),
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
          _applyFilters();
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF48BB78),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF2D3748),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF48BB78)
              : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty || _selectedCategory != null
                ? Icons.search_off
                : Icons.add_location_alt_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != null
                ? 'Aucun POI trouvé'
                : 'Aucun POI créé',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != null
                ? 'Essayez une autre recherche'
                : 'Commencez par ajouter\nvotre premier point d\'intérêt!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (_searchQuery.isEmpty && _selectedCategory == null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                // ✅ Navigate to Add POI screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPOIScreen(),
                  ),
                );
                
                if (result == true) {
                  _loadPOIs();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un POI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48BB78),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
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
}