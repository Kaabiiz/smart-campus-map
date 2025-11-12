<div align="center">

# 🗺️ Smart Campus Map

### *Your Ultimate Campus Navigation Companion*

[![Flutter](https://img.shields.io/badge/Flutter-3.24.5-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.4-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

**A feature-rich Flutter application for intelligent campus navigation with interactive maps, real-time room availability, seamless reservations, and custom POI management.**

[🚀 Features](#-key-features) • [📱 Screenshots](#-app-showcase) • [⚡ Quick Start](#-quick-start) • [🛠️ Tech Stack](#-tech-stack)

---

<img src="assets/banner.png" alt="Smart Campus Map Banner" width="800"/>

</div>

---

## ✨ Key Features

<table>
<tr>
<td width="33%" align="center">

### 🗺️ **Interactive Map**
Real-time campus navigation with color-coded buildings, custom POIs, and smart search

</td>
<td width="33%" align="center">

### 📅 **Smart Reservations**
Book rooms instantly with email confirmations and manage all your bookings

</td>
<td width="33%" align="center">

### 📍 **Custom POIs**
Add, edit, and manage 12 categories of points of interest across campus

</td>
</tr>
</table>

### 🎯 Complete Feature Set

#### **🗺️ Map & Navigation**
- ✅ **Interactive OpenStreetMap** with smooth zoom & pan
- ✅ **6 Building Types** (Classroom, Lab, Library, Restaurant, Admin, Sports)
- ✅ **Color-coded Markers** for instant recognition
- ✅ **Building Selection** with detailed room lists
- ✅ **POI Toggle** - Show/hide custom points of interest
- ✅ **Real-time Updates** - Refresh POIs on demand

#### **🏢 Building & Room Management**
- ✅ **Multi-floor Support** - Navigate through building floors
- ✅ **Real-time Occupancy** tracking with visual indicators:
  - 🟢 **Low** (< 50%)
  - 🟠 **Medium** (50-80%)
  - 🔴 **High** (> 80%)
  - ⚫ **Occupied** (Unavailable)
- ✅ **Room Details** - Capacity, floor number, equipment
- ✅ **Available Rooms List** - Searchable & filterable
- ✅ **One-tap Reservation** from map or list

#### **📅 Reservation System**
- ✅ **Quick Booking** - Date, time slot, and purpose
- ✅ **Email Confirmations** - Automatic confirmation messages
- ✅ **My Reservations** - View upcoming and past bookings
- ✅ **Cancel/Delete** - Manage your reservations with ease
- ✅ **Status Tracking** - Pending, Confirmed, Completed, Cancelled
- ✅ **Tabbed Interface** - Separate upcoming & past views

#### **� POI Management (Full CRUD)**
- ✅ **12 Categories**: Parking, Entrance, Exit, Toilet, ATM, Printer, WiFi, Cafeteria, Study Area, Sports, Emergency, Other
- ✅ **Map Picker** - Tap map to set POI location
- ✅ **Custom Icons & Colors** - 🅿️🚪🚻🏧🖨️📶🍕📚⚽🚨📍
- ✅ **Search & Filter** - Find POIs quickly by name or category
- ✅ **Edit & Delete** - Full management with confirmation dialogs
- ✅ **Database Persistence** - All POIs saved locally

#### **🔍 Advanced Search**
- ✅ **Unified Search** - Find buildings, rooms, and POIs
- ✅ **Real-time Results** - As you type
- ✅ **Smart Filtering** - Filter by category, availability
- ✅ **Direct Navigation** - Tap result to navigate
- ✅ **Empty State Handling** - Helpful messages

#### **� Beautiful UI/UX**
- ✅ **Material Design 3** - Modern, clean interface
- ✅ **Gradient Cards** - Eye-catching statistics
- ✅ **Bottom Sheets** - Smooth info displays
- ✅ **Tab Controllers** - Organized content
- ✅ **Loading States** - Clear feedback
- ✅ **Error Handling** - User-friendly messages
- ✅ **Responsive Layout** - Works on all screen sizes

---

## 📱 App Showcase

<div align="center">

### 🏠 **Home & Navigation**

<table>
<tr>
<td width="33%"><img src="screenshots/01_home_screen.png" alt="Home Screen"/><br/><b>Home Dashboard</b><br/>Real-time stats & quick access</td>
<td width="33%"><img src="screenshots/02_map_view.png" alt="Map View"/><br/><b>Interactive Map</b><br/>Campus-wide navigation</td>
<td width="33%"><img src="screenshots/03_building_detail.png" alt="Building Detail"/><br/><b>Building Details</b><br/>Room list & availability</td>
</tr>
</table>

### 📅 **Reservations**

<table>
<tr>
<td width="33%"><img src="screenshots/04_available_rooms.png" alt="Available Rooms"/><br/><b>Available Rooms</b><br/>Search & filter functionality</td>
<td width="33%"><img src="screenshots/05_reservation_form.png" alt="Reservation Form"/><br/><b>Quick Booking</b><br/>Easy reservation process</td>
<td width="33%"><img src="screenshots/06_my_reservations.png" alt="My Reservations"/><br/><b>My Bookings</b><br/>Upcoming & past reservations</td>
</tr>
</table>

### 📍 **POI Management**

<table>
<tr>
<td width="33%"><img src="screenshots/07_poi_list.png" alt="POI List"/><br/><b>POI List</b><br/>All points of interest</td>
<td width="33%"><img src="screenshots/08_add_poi.png" alt="Add POI"/><br/><b>Add POI</b><br/>Map picker & categories</td>
<td width="33%"><img src="screenshots/09_poi_on_map.png" alt="POI on Map"/><br/><b>POIs on Map</b><br/>Color-coded markers</td>
</tr>
</table>

### 🔍 **Search & Features**

<table>
<tr>
<td width="33%"><img src="screenshots/10_search.png" alt="Search"/><br/><b>Smart Search</b><br/>Buildings, rooms & POIs</td>
<td width="33%"><img src="screenshots/11_filters.png" alt="Filters"/><br/><b>Filter Options</b><br/>Category-based filtering</td>
<td width="33%"><img src="screenshots/12_room_detail.png" alt="Room Detail"/><br/><b>Room Details</b><br/>Occupancy & equipment</td>
</tr>
</table>

### ✨ **Additional Features**

<table>
<tr>
<td width="33%"><img src="screenshots/13_email_confirmation.png" alt="Email"/><br/><b>Email Confirmations</b><br/>Automatic booking emails</td>
<td width="33%"><img src="screenshots/14_poi_details.png" alt="POI Details"/><br/><b>POI Details</b><br/>Bottom sheet info</td>
<td width="33%"><img src="screenshots/15_statistics.png" alt="Statistics"/><br/><b>Statistics</b><br/>Real-time analytics</td>
</tr>
</table>

</div>

---

## 🛠️ Tech Stack

<div align="center">

| Technology | Purpose | Version |
|------------|---------|---------|
| ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white) | Framework | 3.24.5 |
| ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white) | Language | 3.5.4 |
| ![SQLite](https://img.shields.io/badge/SQLite-003B57?style=flat&logo=sqlite&logoColor=white) | Database | Latest |
| ![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-7EBC6F?style=flat&logo=openstreetmap&logoColor=white) | Maps | OSM Tiles |
| ![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=flat&logo=material-design&logoColor=white) | UI/UX | MD3 |

</div>

### 📦 Core Dependencies

```yaml
dependencies:
  flutter_map: ^8.2.2      # Interactive maps
  latlong2: ^0.9.0         # Geographic coordinates
  sqflite: ^2.0.0          # Local database
  path: ^1.8.0             # Path utilities
  mailer: ^6.0.0           # Email service
```

---

## ⚡ Quick Start

### 📋 Prerequisites

```bash
✅ Flutter SDK 3.0+
✅ Dart SDK 3.0+
✅ Android Studio / VS Code
✅ Git
```

### 🚀 Installation

```bash
# Clone repository
git clone https://github.com/Kaabiiz/smart-campus-map.git

# Navigate to directory
cd smart-campus-map

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 🎮 Available Commands

```bash
flutter run              # Debug mode
flutter run --release    # Release mode
flutter test            # Run tests
flutter clean           # Clean build
flutter doctor          # Check setup
```

---

## 📁 Project Structure

```
smart_campus_map/
├── lib/
│   ├── models/              # Data models
│   │   ├── building.dart
│   │   ├── room.dart
│   │   ├── poi.dart
│   │   └── reservation.dart
│   ├── screens/             # UI screens
│   │   ├── home_screen.dart
│   │   ├── map_screen.dart
│   │   ├── my_reservations_screen.dart
│   │   ├── available_rooms_screen.dart
│   │   ├── room_reservation_screen.dart
│   │   └── poi_list_screen.dart
│   ├── services/            # Business logic
│   │   ├── database_helper.dart
│   │   ├── reservation_service.dart
│   │   ├── poi_service.dart
│   │   └── email_service.dart
│   ├── widgets/             # Reusable widgets
│   │   ├── stat_card_widget.dart
│   │   ├── reservation_card_widget.dart
│   │   └── home_banner_widget.dart
│   ├── utils/               # Utilities
│   │   └── mock_data.dart
│   └── main.dart            # Entry point
├── assets/                  # Images & icons
├── screenshots/             # App screenshots
└── pubspec.yaml            # Dependencies
```

---

## 🎯 Key Highlights

<div align="center">

| Feature | Description |
|---------|-------------|
| **🗺️ Real-time Map** | OpenStreetMap integration with custom markers |
| **📊 Live Occupancy** | Color-coded room availability (Green/Orange/Red) |
| **� 12 POI Categories** | Parking, Toilets, ATMs, WiFi, Cafeterias, etc. |
| **� Smart Booking** | Date picker, time slots, instant confirmations |
| **� Email System** | Automatic confirmation emails with templates |
| **� SQLite Database** | Local persistence for POIs & reservations |
| **� Unified Search** | Find buildings, rooms, and POIs instantly |
| **� Material Design 3** | Modern, beautiful, and responsive UI |

</div>

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. 🍴 Fork the repository
2. 🔨 Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. ✨ Commit changes (`git commit -m 'Add AmazingFeature'`)
4. 📤 Push to branch (`git push origin feature/AmazingFeature`)
5. 🎉 Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

<div align="center">

**Ahmed Kaabi**

[![GitHub](https://img.shields.io/badge/GitHub-Kaabiiz-181717?style=for-the-badge&logo=github)](https://github.com/Kaabiiz)
[![Email](https://img.shields.io/badge/Email-kaabi.ahmed@outlook.com-0078D4?style=for-the-badge&logo=microsoft-outlook&logoColor=white)](mailto:kaabi.ahmed@outlook.com)

*Building the future of campus navigation* 🚀

</div>

---

## 🙏 Acknowledgments

- 🗺️ [OpenStreetMap](https://www.openstreetmap.org/) - Free map tiles
- 💙 [Flutter Team](https://flutter.dev/) - Amazing framework
- 📦 [flutter_map](https://pub.dev/packages/flutter_map) - Map package
- ☕ Coffee - For keeping me awake!

---

## ⭐ Show Your Support

If you found this project helpful:

- ⭐ Star the repository
- 🍴 Fork and contribute
- 📢 Share with others
- 💬 Provide feedback

---

<div align="center">

### 🚀 Ready to Navigate Your Campus?

**Made with ❤️ using Flutter**

[⬆ Back to Top](#-smart-campus-map)

</div>