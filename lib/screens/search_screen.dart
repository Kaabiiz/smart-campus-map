import 'package:flutter/material.dart';
import '../models/building.dart';
import '../utils/mock_data.dart';
import '../utils/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Building> _searchResults = [];
  List<Building> _allBuildings = [];

  @override
  void initState() {
    super.initState();
    _allBuildings = MockData.getBuildings();
    _searchResults = _allBuildings;
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = _allBuildings;
      });
      return;
    }

    setState(() {
      _searchResults = MockData.searchBuildings(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Rechercher un bâtiment...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _searchResults.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final building = _searchResults[index];
                return _buildBuildingCard(building);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingCard(Building building) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.buildingColors[building.type.name]?.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getBuildingIcon(building.type),
            color: AppConstants.buildingColors[building.type.name],
            size: 24,
          ),
        ),
        title: Text(
          building.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(building.typeLabel, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              building.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pop(context, building),
      ),
    );
  }

  IconData _getBuildingIcon(BuildingType type) {
    switch (type) {
      case BuildingType.classroom:
        return Icons.school;
      case BuildingType.administration:
        return Icons.business;
      case BuildingType.library:
        return Icons.local_library;
      case BuildingType.restaurant:
        return Icons.restaurant;
      case BuildingType.lab:
        return Icons.science;
      case BuildingType.sports:
        return Icons.sports_soccer;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}