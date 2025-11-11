# 🗺️ Smart Campus Map

An interactive Flutter application for campus navigation featuring indoor maps, real-time room occupancy tracking, and an integrated reservation system.

## ✨ Features

### 🗺️ Interactive Map
- Campus-wide interactive map with building markers
- Color-coded building types (classrooms, labs, administration, etc.)
- Real-time occupancy indicators on building markers
- Points of Interest (POIs) - parking, entrances, facilities
- Filter buildings by type

### 🏢 Building Information
- Detailed building information and descriptions
- Floor-by-floor navigation
- Building statistics (capacity, occupancy, floors)
- Indoor floor plans with interactive room selection

### 🚪 Room Management
- Real-time room occupancy tracking
- Visual occupancy indicators (color-coded)
- Room capacity and equipment information
- Availability status (available/occupied)

### 📅 Reservation System
- Book rooms with date and time slot selection
- View available time slots
- Reservation confirmation system
- Purpose/reason for reservation

### 🔍 Advanced Search
- Search across buildings, rooms, and POIs
- Filter results by type
- Real-time search with instant results
- Smart suggestions

## 🛠️ Technologies Used

- **Framework:** Flutter 3.x
- **Maps:** flutter_map + OpenStreetMap
- **State Management:** StatefulWidget (can be migrated to Provider/Riverpod)
- **UI Components:** Material Design 3

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_map: ^8.2.2
  latlong2: ^0.9.0
  cupertino_icons: ^1.0.8
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/smart-campus-map.git
   cd smart-campus-map
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

*(Add screenshots here after deployment)*

## 🏗️ Project Structure

```
lib/
├── models/              # Data models
│   ├── building.dart
│   ├── room.dart
│   ├── floor_plan.dart
│   ├── poi.dart
│   └── reservation.dart
├── screens/             # UI screens
│   ├── map_screen.dart
│   ├── building_detail_screen.dart
│   ├── floor_plan_screen.dart
│   ├── room_reservation_screen.dart
│   └── search_screen.dart
├── services/            # Business logic
│   └── reservation_service.dart
├── utils/               # Utilities
│   ├── constants.dart
│   ├── mock_data.dart
│   └── helpers.dart
└── main.dart           # App entry point
```

## 🎯 Features Roadmap

### Completed ✅
- [x] Interactive campus map
- [x] Building markers with types
- [x] Building detail screens
- [x] Floor plans with occupancy
- [x] Room reservation system
- [x] Enhanced search functionality
- [x] Real-time occupancy visualization

### Planned 🚧
- [ ] User authentication
- [ ] Personal POI bookmarks
- [ ] Route navigation between buildings
- [ ] Push notifications for reservations
- [ ] QR code check-in system
- [ ] Accessibility features
- [ ] Dark mode support
- [ ] Backend integration (API)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is MIT licensed.

## 👥 Authors

- **Your Name** - *Initial work*

## 🙏 Acknowledgments

- OpenStreetMap for map tiles
- Flutter team for the amazing framework
- flutter_map package contributors

## 📧 Contact

Your Name - your.email@example.com

Project Link: [https://github.com/YOUR_USERNAME/smart-campus-map](https://github.com/YOUR_USERNAME/smart-campus-map)
```