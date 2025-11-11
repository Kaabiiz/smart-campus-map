<div align="center">

# 🗺️ Smart Campus Map

### *Navigate your campus like never before!*

[![Flutter](https://img.shields.io/badge/Flutter-3.24.5-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.4-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/Kaabiiz/smart-campus-map?style=for-the-badge)](https://github.com/Kaabiiz/smart-campus-map/stargazers)

**An intelligent Flutter application for campus navigation with indoor maps, real-time room occupancy, and seamless reservation system.**

[🚀 Getting Started](#-getting-started) • [✨ Features](#-features) • [� Screenshots](#-screenshots) • [🤝 Contributing](#-contributing)

---

</div>

## 🌟 Why Smart Campus Map?

Tired of getting lost on campus? Need to find an available study room? **Smart Campus Map** is your ultimate campus companion that combines:

- 🗺️ **Interactive Navigation** - Explore your entire campus with an intuitive map interface
- 🏢 **Indoor Floor Plans** - Never get lost inside buildings again
- 📊 **Real-time Occupancy** - See which rooms are available at a glance
- 📅 **Smart Reservations** - Book rooms instantly with just a few taps
- 🔍 **Powerful Search** - Find any building, room, or facility in seconds

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🗺️ Interactive Campus Map
- 📍 Campus-wide navigation with smart markers
- 🎨 Color-coded building types
- 📊 Real-time occupancy indicators
- 📌 Points of Interest (parking, ATMs, cafeterias)
- 🔽 Filter buildings by category

</td>
<td width="50%">

### 🏢 Building Intelligence
- 📋 Detailed building information
- 🏗️ Multi-floor navigation
- 📈 Live capacity & occupancy stats
- 🗺️ Interactive indoor floor plans
- 🎯 Quick room locator

</td>
</tr>
<tr>
<td width="50%">

### 🚪 Smart Room Management
- ⚡ Real-time occupancy tracking
- 🚦 Visual status indicators (green/orange/red)
- 🛋️ Room capacity & equipment details
- ✅ Instant availability status
- 📱 Equipment list (projectors, PCs, etc.)

</td>
<td width="50%">

### 📅 Seamless Reservations
- 📆 Date & time slot picker
- ⏰ View all available time slots
- ✉️ Instant confirmation system
- 📝 Add purpose/notes to reservations
- 🔔 Booking history (coming soon)

</td>
</tr>
</table>

### 🔍 Advanced Search System
- 🔎 Search buildings, rooms, AND POIs simultaneously
- 🏷️ Smart filtering by type
- ⚡ Real-time results as you type
- 💡 Intelligent suggestions
- 🎯 Direct navigation to results

---

## 🛠️ Tech Stack

<div align="center">

| Category | Technology |
|----------|-----------|
| **Framework** | ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white) Flutter 3.24.5 |
| **Language** | ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white) Dart 3.5.4 |
| **Maps** | ![OpenStreetMap](https://img.shields.io/badge/OpenStreetMap-7EBC6F?style=flat&logo=openstreetmap&logoColor=white) flutter_map + OSM |
| **UI/UX** | ![Material Design](https://img.shields.io/badge/Material%20Design%203-757575?style=flat&logo=material-design&logoColor=white) Material Design 3 |
| **State** | StatefulWidget (Provider/Riverpod ready) |

</div>

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_map: ^8.2.2      # Interactive maps
  latlong2: ^0.9.0         # Geographic coordinates
  cupertino_icons: ^1.0.8  # iOS-style icons
```

---

## 🚀 Getting Started

### 📋 Prerequisites

Before you begin, ensure you have:

- ✅ [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
- ✅ [Dart SDK](https://dart.dev/get-dart) (3.0+)
- ✅ [Android Studio](https://developer.android.com/studio) / [VS Code](https://code.visualstudio.com/)
- ✅ [Git](https://git-scm.com/downloads)
- ✅ An Android/iOS device or emulator

### ⚡ Quick Start

```bash
# 1️⃣ Clone the repository
git clone https://github.com/Kaabiiz/smart-campus-map.git

# 2️⃣ Navigate to project directory
cd smart-campus-map

# 3️⃣ Install dependencies
flutter pub get

# 4️⃣ Run the app
flutter run
```

### 🎮 Development Commands

```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Run tests
flutter test

# Check for issues
flutter doctor

# Clean build files
flutter clean
```

---

## � Screenshots

<div align="center">

### Coming Soon! 🎨

*Screenshots will be added after deployment*

</div>

---

## 🏗️ Project Structure

```
smart_campus_map/
│
├── 📱 lib/
│   ├── 📦 models/              # Data models
│   │   ├── building.dart       # Building entity
│   │   ├── room.dart           # Room entity
│   │   ├── floor_plan.dart     # Floor plan data
│   │   ├── poi.dart            # Point of Interest
│   │   └── reservation.dart    # Reservation system
│   │
│   ├── 🎨 screens/             # UI Screens
│   │   ├── map_screen.dart               # Main map view
│   │   ├── building_detail_screen.dart   # Building info
│   │   ├── floor_plan_screen.dart        # Indoor maps
│   │   ├── room_reservation_screen.dart  # Booking system
│   │   └── search_screen.dart            # Search interface
│   │
│   ├── ⚙️ services/            # Business Logic
│   │   └── reservation_service.dart      # Reservation handler
│   │
│   ├── 🛠️ utils/               # Utilities
│   │   ├── constants.dart      # App constants
│   │   ├── mock_data.dart      # Sample data
│   │   └── helpers.dart        # Helper functions
│   │
│   └── 🚀 main.dart            # App entry point
│
├── 🎨 assets/                  # Assets (images, icons)
├── 🤖 android/                 # Android specific files
├── 🍎 ios/                     # iOS specific files
├── � web/                     # Web specific files
├── 📝 pubspec.yaml             # Project dependencies
└── 📖 README.md                # You are here!
```

---

## 🎯 Roadmap

### ✅ Completed Features (v1.0)

- [x] 🗺️ Interactive campus map with markers
- [x] 🏢 Building detail screens with stats
- [x] 🏗️ Multi-floor support
- [x] 🎨 Indoor floor plans with visualization
- [x] 📅 Complete reservation system
- [x] 🔍 Enhanced search (buildings, rooms, POIs)
- [x] 📊 Real-time occupancy tracking
- [x] 🎨 Material Design 3 UI

### 🚧 Coming Soon (v2.0)

- [ ] 🔐 User authentication & profiles
- [ ] ⭐ Personal POI bookmarks
- [ ] 🧭 Route navigation & pathfinding
- [ ] 🔔 Push notifications for reservations
- [ ] 📱 QR code check-in system
- [ ] ♿ Accessibility features
- [ ] 🌙 Dark mode support
- [ ] 🌐 Backend API integration

### 🔮 Future Ideas (v3.0+)

- [ ] � AI-powered room recommendations
- [ ] 📊 Analytics dashboard
- [ ] 👥 Social features (find friends)
- [ ] 🎫 Event management
- [ ] 🚗 Parking availability
- [ ] 🍽️ Cafeteria menu integration
- [ ] 📚 Library seat booking
- [ ] 🏃 Fitness tracking

---

## 🤝 Contributing

We love contributions! 💙

### How to Contribute

1. 🍴 **Fork** the repository
2. 🔨 **Create** your feature branch
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. ✨ **Commit** your changes
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
4. 📤 **Push** to the branch
   ```bash
   git push origin feature/AmazingFeature
   ```
5. 🎉 **Open** a Pull Request

### 📝 Contribution Guidelines

- Write clear commit messages
- Follow the existing code style
- Add comments for complex logic
- Update documentation if needed
- Test your changes thoroughly

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License - Feel free to use this project for learning or commercial purposes!
```

---

## �‍💻 Author

<div align="center">

### **Ahmed Kaabi** 

[![GitHub](https://img.shields.io/badge/GitHub-Kaabiiz-181717?style=for-the-badge&logo=github)](https://github.com/Kaabiiz)
[![Email](https://img.shields.io/badge/Email-kaabi.ahmed@outlook.com-0078D4?style=for-the-badge&logo=microsoft-outlook&logoColor=white)](mailto:kaabi.ahmed@outlook.com)

*Building the future of campus navigation* 🚀

</div>

---

## 🙏 Acknowledgments

A big thank you to:

- 🗺️ **[OpenStreetMap](https://www.openstreetmap.org/)** - For providing free map tiles
- 💙 **[Flutter Team](https://flutter.dev/)** - For the amazing framework
- 📦 **[flutter_map](https://pub.dev/packages/flutter_map)** - For the excellent map package
- 🎨 **Material Design** - For the beautiful UI components
- ☕ **Coffee** - For keeping me awake during development

---

## 📞 Support

Need help? Have questions?

- 📧 **Email:** [kaabi.ahmed@outlook.com](mailto:kaabi.ahmed@outlook.com)
- 🐛 **Issues:** [Create an issue](https://github.com/Kaabiiz/smart-campus-map/issues)
- 💬 **Discussions:** [Start a discussion](https://github.com/Kaabiiz/smart-campus-map/discussions)

---

## ⭐ Show Your Support

If you like this project, please consider:

- ⭐ **Starring** the repository
- 🍴 **Forking** to contribute
- 📢 **Sharing** with others
- 💬 **Providing feedback**

---

<div align="center">

### 🚀 Ready to Navigate?

**[Get Started Now](#-getting-started)** | **[View Demo](#-screenshots)** | **[Contribute](#-contributing)**

---

Made with ❤️ and Flutter

**[⬆ Back to Top](#-smart-campus-map)**

</div>