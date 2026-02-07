# Aura App - Architecture Documentation

## 📁 Folder Structure

```
lib/
├── core/                           # Core functionality shared across features
│   ├── data/                      # Data layer
│   │   └── media_repository.dart  # Audio & Video scanning repository
│   ├── models/                    # Data models
│   │   ├── song_model.dart       # Song data model
│   │   └── video_model.dart      # Video data model
│   ├── navigation/                # Navigation management
│   │   ├── navigation_controller.dart    # Bottom nav controller
│   │   └── tab_controller_manager.dart   # Home tabs controller
│   ├── presentation/              # Shared UI components
│   │   └── widgets/
│   │       └── glass_container.dart
│   ├── providers/                 # Global state providers
│   │   ├── audio_provider.dart   # Audio playback provider
│   │   └── media_provider.dart   # Media (songs/videos) provider
│   ├── services/                  # Core services
│   │   ├── audio_handler.dart    # Background audio service
│   │   ├── permission_service.dart
│   │   └── storage_service.dart  # Hive storage
│   └── theme/                     # App theming
│       ├── app_colors.dart
│       └── app_theme.dart
│
├── features/                       # Feature modules
│   ├── home/                      # Home/Dashboard feature
│   │   ├── data/
│   │   │   └── audio_repository.dart
│   │   └── presentation/
│   │       ├── home_page.dart    # Main dashboard with 6 tabs
│   │       ├── providers/
│   │       │   └── song_provider.dart
│   │       ├── tabs/             # 6 tabs
│   │       │   ├── songs_tab.dart
│   │       │   ├── videos_tab.dart
│   │       │   ├── playlists_tab.dart
│   │       │   ├── folders_tab.dart
│   │       │   ├── artists_tab.dart
│   │       │   └── albums_tab.dart
│   │       └── widgets/
│   │           └── song_tile.dart
│   │
│   ├── library/                   # Library feature
│   │   ├── data/
│   │   │   └── favorites_repository.dart
│   │   └── presentation/
│   │       ├── library_screen.dart
│   │       └── providers/
│   │           └── favorites_provider.dart
│   │
│   ├── main/                      # Main screen with bottom nav
│   │   └── presentation/
│   │       └── main_screen.dart  # PageController navigation
│   │
│   ├── player/                    # Player feature
│   │   └── presentation/
│   │       └── player_page.dart
│   │
│   ├── search/                    # Search feature
│   │   └── presentation/
│   │       └── search_screen.dart
│   │
│   └── settings/                  # Settings feature
│       └── presentation/
│           └── settings_screen.dart
│
└── main.dart                      # App entry point
```

## 🏗️ Architecture Overview

### 1. Navigation Layer

#### MainScreen Navigation (Bottom Navigation Bar)
- **File**: `features/main/presentation/main_screen.dart`
- **Controller**: `core/navigation/navigation_controller.dart`
- **Features**:
  - Uses `PageController` for smooth page transitions
  - 4 main screens: Home, Search, Library, Settings
  - Swipe gesture support
  - Animated bottom navigation bar

#### Home Dashboard Tabs
- **File**: `features/home/presentation/home_page.dart`
- **Controller**: `core/navigation/tab_controller_manager.dart`
- **Features**:
  - 6 tabs: Songs, Videos, Playlists, Folders, Artists, Albums
  - TabController with state management
  - Scrollable tab bar

### 2. Data Layer

#### MediaRepository
- **File**: `core/data/media_repository.dart`
- **Responsibilities**:
  - Scan audio files using `on_audio_query`
  - Scan video files from device storage
  - Retrieve albums, artists, playlists
  - Search functionality for both audio and video
  - Get songs by album/artist

#### Data Models

**SongModel** (`core/models/song_model.dart`)
```dart
- id, title, artist, album
- albumArt, duration, filePath
- size, genre, year, composer
- trackNumber, dateAdded, dateModified
- Utility methods: formattedDuration, formattedSize
```

**VideoModel** (`core/models/video_model.dart`)
```dart
- id, title, filePath, duration
- thumbnail, size, width, height
- resolution, dateAdded, dateModified
- folderName, mimeType
- Utility methods: formattedDuration, formattedSize, qualityLabel
```

### 3. State Management (Riverpod)

#### Media Providers (`core/providers/media_provider.dart`)

**SongsProvider**
- Manages all songs state
- Loading, error handling
- Refresh and search functionality

**VideosProvider**
- Manages all videos state
- Loading, error handling
- Refresh and search functionality

**Other Providers**
- `albumsProvider` - FutureProvider for albums
- `artistsProvider` - FutureProvider for artists
- `playlistsProvider` - FutureProvider for playlists
- `songsFromAlbumProvider` - Family provider for album songs
- `songsFromArtistProvider` - Family provider for artist songs

#### Navigation Providers

**NavigationController** (`core/navigation/navigation_controller.dart`)
- Manages bottom navigation state
- PageController lifecycle
- Smooth page transitions

**TabControllerManager** (`core/navigation/tab_controller_manager.dart`)
- Manages home dashboard tabs
- Current tab state
- Tab switching logic

### 4. Data Flow

```
User Action
    ↓
UI (Presentation Layer)
    ↓
Provider (State Management)
    ↓
Repository (Data Layer)
    ↓
on_audio_query / File System
    ↓
Data Models
    ↓
Provider (Update State)
    ↓
UI (Re-render)
```

### 5. Key Features

#### Audio Scanning
- Uses `on_audio_query` package
- Retrieves metadata: title, artist, album, duration, etc.
- Supports sorting and filtering
- Album artwork support

#### Video Scanning
- Scans common video directories
- Supports multiple formats: mp4, mkv, avi, mov, etc.
- Extracts file metadata
- Quality detection (SD, HD, Full HD, 4K)

#### Navigation
- Smooth PageView transitions
- Swipe gesture support
- Animated bottom navigation
- Tab-based content organization

#### State Management
- Riverpod for reactive state
- Loading and error states
- Automatic UI updates
- Provider composition

## 🔄 Usage Examples

### Loading Songs
```dart
// In any widget
final songsState = ref.watch(songsProvider);

if (songsState.isLoading) {
  return CircularProgressIndicator();
}

if (songsState.error != null) {
  return Text('Error: ${songsState.error}');
}

return ListView.builder(
  itemCount: songsState.songs.length,
  itemBuilder: (context, index) {
    final song = songsState.songs[index];
    return ListTile(
      title: Text(song.title),
      subtitle: Text(song.artist),
    );
  },
);
```

### Loading Videos
```dart
final videosState = ref.watch(videosProvider);

// Similar to songs
```

### Navigation
```dart
// Navigate to a specific screen
final navigationController = ref.read(navigationControllerProvider.notifier);
navigationController.navigateToIndex(2); // Go to Library
```

### Tab Switching
```dart
final tabController = ref.read(tabControllerManagerProvider.notifier);
tabController.changeTab(1); // Switch to Videos tab
```

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^3.2.1      # State management
  on_audio_query: ^2.9.0        # Audio scanning
  video_player: ^2.10.1         # Video playback
  chewie: ^1.13.0               # Video player UI
  just_audio: ^0.10.5           # Audio playback
  audio_service: ^0.18.18       # Background audio
  hive: ^2.2.3                  # Local storage
  permission_handler: ^12.0.1   # Permissions
```

## 🎯 Next Steps

1. Implement UI for each tab
2. Add video player functionality
3. Implement playlist management
4. Add folder-based organization
5. Implement search functionality
6. Add favorites/library features
7. Implement settings screen

## 📝 Notes

- All data operations are asynchronous
- Error handling is built into providers
- Models are immutable with copyWith methods
- Repository pattern for data access
- Clean separation of concerns
- Scalable architecture for future features
