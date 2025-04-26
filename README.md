# 🎬 Movie App - Flutter 

<img width="807" alt="image" src="https://github.com/user-attachments/assets/69ecede3-615c-4506-bba1-e71fbbbe27f3" />


---

## ✨ Features

### 🎞️ Movie Section
- Trending movies with a beautiful UI
- View comprehensive movie details
- Carousel display for featured movies
- Infinite scroll pagination

### 👤 User Management
- Add and manage users
- Online/offline synchronization
- Background data synchronization
- Connectivity awareness

### 📴 Offline Support
- View cached movie data when offline
- Add users offline with automatic sync when back online
- Background synchronization of offline data
- Visual offline status indicators

---

## 🛠 Technical Highlights

### Core Packages

| Package | Purpose |
|:--------|:--------|
| `drift` | Local SQLite database management |
| `dio` | HTTP client for API calls |
| `riverpod` | Efficient state management |
| `connectivity_plus` | Real-time network status detection |
| `workmanager` | Background task scheduling |
| `cached_network_image` | Intelligent image caching |
| `carousel_slider` | Movie carousel display |
| `intl` | Internationalization support |
| `pull_to_refresh` | Refresh functionality |

### Architecture

```bash
📁 lib/
  ├── data
  │   ├── https.dart
  │   └── local
  │       ├── database.dart
  │       ├── database.g.dart
  │       └── db_provider.dart
  ├── features
  │   ├── movies
  │   │   ├── controllers
  │   │   │   ├── movie_controller.dart
  │   │   │   └── movie_detail_controller.dart
  │   │   ├── models
  │   │   │   ├── movie_detail_model.dart
  │   │   │   └── movie_model.dart
  │   │   ├── services
  │   │   │   ├── movie_detail_services.dart
  │   │   │   └── movie_services.dart
  │   │   ├── viewModels
  │   │   │   ├── movie_detail_view_model.dart
  │   │   │   └── movie_view_model.dart
  │   │   └── views
  │   │       ├── movie_detail_screen.dart
  │   │       └── movie_list_screen.dart
  │   ├── offlineRecords
  │   │   └── offline_records.dart
  │   └── users
  │       ├── controllers
  │       │   ├── unsynced_counter_provider.dart
  │       │   └── user_controller.dart
  │       ├── models
  │       │   └── user_model.dart
  │       ├── services
  │       │   └── user_services.dart
  │       ├── viewModels
  │       │   └── user_view_model.dart
  │       └── views
  │           └── user_screen.dart
  ├── main.dart
  ├── services
  │   └── sync_service.dart
  └── Utilities
      ├── enums.dart
      └── Routes
          ├── app_router.dart
          └── route_names.dart
```

- **Data Layer**: Local database (Drift) + Remote APIs (Dio)
- **Domain Layer**: Models and Services
- **Presentation Layer**: ViewModels, Controllers, UI Components (Riverpod)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.7.2)
- Dart SDK (3.7.2)
- Android Studio / Xcode (for device emulators)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/gopalkrushnas063/flutter_movie_app/
   cd flutter_movie_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add API Keys**

   Create a `.env` file at the project root:

   ```env
   TMDB_API_KEY=your_tmdb_api_key
   OMDB_API_KEY=your_omdb_api_key
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🎨 UI Components

| Screen             | Description |
|:-------------------|:------------|
| Splash Screen      | Initial loading animation |
| User List Screen   | Displays users with offline status indicators |
| Movie Grid Screen  | Responsive movie grid and trending carousel |
| Movie Details      | Interactive bottom sheet for movie information |

---

## 🔄 Sync Flow

![deepseek_mermaid_20250426_773e2a](https://github.com/user-attachments/assets/1a253850-d040-4283-b14e-85a56e8a5424)


---

## 📸 Screenshots

| User Screen | Movie List | Movie Details |
|:-----------:|:----------:|:-------------:|
| <img width="150" alt="image" src="https://github.com/user-attachments/assets/b70bc8d2-32b1-4cd8-baba-11b61cb22ad6" /> | <img width="150" alt="image" src="https://github.com/user-attachments/assets/94930906-be48-4d10-af7a-dfdde5507497" /> | <img width="150" alt="image" src="https://github.com/user-attachments/assets/565ee995-479b-4e47-886c-519f7331e800" /> |




