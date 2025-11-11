import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AppConstants {
  // Campus Center (Esprit Tunis)
  static const LatLng campusCenter = LatLng(36.8981, 10.1897);
  
  static const double defaultZoom = 17.0;
  
  // Colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFFFF5722);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  
  static const Map<String, Color> buildingColors = {
    'classroom': Color(0xFF4CAF50),
    'administration': Color(0xFF2196F3),
    'library': Color(0xFF9C27B0),
    'restaurant': Color(0xFFFF9800),
    'lab': Color(0xFFF44336),
    'sports': Color(0xFF00BCD4),
  };
  
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );
  
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 500);
}