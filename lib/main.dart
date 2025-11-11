import 'package:flutter/material.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const SmartCampusMapApp());
}

class SmartCampusMapApp extends StatelessWidget {
  const SmartCampusMapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Campus Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}