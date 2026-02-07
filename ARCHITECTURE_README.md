# Aura - Offline Music/Video App Architecture

## 🎯 Overview

यह document **Aura App** के logical structure और architecture को explain करता है। इस app में clean architecture pattern का use किया गया है जो scalable और maintainable है।

## 📋 Table of Contents

1. [Navigation System](#navigation-system)
2. [Data Layer](#data-layer)
3. [State Management](#state-management)
4. [Folder Structure](#folder-structure)
5. [Usage Guide](#usage-guide)

---

## 🧭 Navigation System

### 1. MainScreen Navigation (Bottom Navigation Bar)

**Location**: `lib/features/main/presentation/main_screen.dart`

**Features**:
- ✅ PageController के साथ smooth transitions
- ✅ 4 main screens: Home, Search, Library, Settings
- ✅ Swipe gesture support
- ✅ Animated bottom navigation bar

**Controller**: `lib/core/navigation/navigation_controller.dart`

```dart
// Usage
final navigationController = ref.read(navigationControllerProvider.notifier);
navigationController.navigateToIndex(2); // Navigate to Library
```

**Key Methods**:
- `navigateToIndex(int index)` - Navigate to specific screen
- `onPageChanged(int index)` - Handle page swipe

---

### 2. Home Dashboard Tabs

**Location**: `lib/features/home/presentation/home_page.dart`

**Features**:
- ✅ 6 tabs: Songs, Videos, Playlists, Folders, Artists, Albums
- ✅ TabController with state management
- ✅ Scrollable tab bar

**Controller**: `lib/core/navigation/tab_controller_manager.dart`

```dart
// Usage
final tabController = ref.read(tabControllerManagerProvider.notifier);
tabController.changeTab(1); // Switch to Videos tab
```

---

## 💾 Data Layer

### MediaRepository

**Location**: `lib/core/data/media_repository.dart`

**Responsibilities**:
- 🎵 Audio files को scan करना (using `on_audio_query`)
- 🎬 Video files को scan करना (file system से)
- 📀 Albums, Artists, Playlists retrieve करना
- 🔍 Search functionality (audio + video)

**Key Methods**:

```dart
// Audio
Future<List<SongModel>> scanAudioFiles()
Future<List<AlbumModel>> getAlbums()
Future<List<ArtistModel>> getArtists()
Future<List<SongModel>> getSongsFromAlbum(int albumId)
Future<List<SongModel>> searchSongs(String query)

// Video
Future<List<VideoModel>> scanVideoFiles()
Future<List<VideoModel>> searchVideos(String query)
```

---

### Data Models

#### 1. SongModel

**Location**: `lib/core/models/song_model.dart`

**Properties**:
```dart
- id, title, artist, album
- albumArt, duration, filePath
- size, genre, year, composer
- trackNumber, dateAdded, dateModified
```

**Utility Methods**:
- `formattedDuration` - "3:45" format में duration
- `formattedSize` - "3.5 MB" format में size
- `toMap()` / `fromMap()` - Storage के लिए conversion

---

#### 2. VideoModel

**Location**: `lib/core/models/video_model.dart`

**Properties**:
```dart
- id, title, filePath, duration
- thumbnail, size, width, height
- resolution, dateAdded, dateModified
- folderName, mimeType
```

**Utility Methods**:
- `formattedDuration` - "1:23:45" format में duration
- `formattedSize` - "125.5 MB" format में size
- `qualityLabel` - "HD", "Full HD", "4K" etc.
- `displayResolution` - "1920x1080"

---

## 🔄 State Management (Riverpod)

### Media Providers

**Location**: `lib/core/providers/media_provider.dart`

#### 1. SongsProvider

```dart
final songsState = ref.watch(songsProvider);

// Properties
songsState.songs        // List<SongModel>
songsState.isLoading    // bool
songsState.error        // String?

// Methods
ref.read(songsProvider.notifier).loadSongs()
ref.read(songsProvider.notifier).refresh()
ref.read(songsProvider.notifier).search(query)
```

#### 2. VideosProvider

```dart
final videosState = ref.watch(videosProvider);

// Properties
videosState.videos      // List<VideoModel>
videosState.isLoading   // bool
videosState.error       // String?

// Methods
ref.read(videosProvider.notifier).loadVideos()
ref.read(videosProvider.notifier).refresh()
ref.read(videosProvider.notifier).search(query)
```

#### 3. Other Providers

```dart
// Albums
final albumsAsync = ref.watch(albumsProvider);

// Artists
final artistsAsync = ref.watch(artistsProvider);

// Playlists
final playlistsAsync = ref.watch(playlistsProvider);

// Songs from specific album
final songsAsync = ref.watch(songsFromAlbumProvider(albumId));

// Songs from specific artist
final songsAsync = ref.watch(songsFromArtistProvider(artistId));
```

---

## 📁 Folder Structure

```
lib/
├── core/
│   ├── data/
│   │   └── media_repository.dart       # Audio + Video scanning
│   ├── models/
│   │   ├── song_model.dart            # Song data model
│   │   └── video_model.dart           # Video data model
│   ├── navigation/
│   │   ├── navigation_controller.dart  # Bottom nav
│   │   └── tab_controller_manager.dart # Home tabs
│   ├── providers/
│   │   ├── audio_provider.dart        # Audio playback
│   │   └── media_provider.dart        # Media state
│   └── services/
│       ├── audio_handler.dart         # Background audio
│       ├── permission_service.dart
│       └── storage_service.dart       # Hive storage
│
├── features/
│   ├── home/
│   │   └── presentation/
│   │       ├── home_page.dart         # 6 tabs dashboard
│   │       └── tabs/
│   │           ├── songs_tab.dart
│   │           ├── videos_tab.dart
│   │           ├── playlists_tab.dart
│   │           ├── folders_tab.dart
│   │           ├── artists_tab.dart
│   │           └── albums_tab.dart
│   │
│   ├── main/
│   │   └── presentation/
│   │       └── main_screen.dart       # PageController navigation
│   │
│   ├── library/
│   ├── player/
│   ├── search/
│   └── settings/
│
└── examples/
    └── architecture_usage_examples.dart # Usage examples
```

---

## 📖 Usage Guide

### 1. Songs को Load करना

```dart
class SongsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends ConsumerState<SongsTab> {
  @override
  void initState() {
    super.initState();
    // Load songs on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(songsProvider.notifier).loadSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final songsState = ref.watch(songsProvider);

    if (songsState.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (songsState.error != null) {
      return Center(child: Text('Error: ${songsState.error}'));
    }

    return ListView.builder(
      itemCount: songsState.songs.length,
      itemBuilder: (context, index) {
        final song = songsState.songs[index];
        return ListTile(
          title: Text(song.title),
          subtitle: Text('${song.artist} • ${song.formattedDuration}'),
          trailing: Text(song.formattedSize),
        );
      },
    );
  }
}
```

### 2. Videos को Load करना

```dart
class VideosTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends ConsumerState<VideosTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videosProvider.notifier).loadVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final videosState = ref.watch(videosProvider);

    if (videosState.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: videosState.videos.length,
      itemBuilder: (context, index) {
        final video = videosState.videos[index];
        return ListTile(
          title: Text(video.title),
          subtitle: Text('${video.qualityLabel} • ${video.formattedDuration}'),
        );
      },
    );
  }
}
```

### 3. Albums को Display करना

```dart
class AlbumsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);

    return albumsAsync.when(
      data: (albums) => ListView.builder(
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return ListTile(
            title: Text(album.album),
            subtitle: Text('${album.numOfSongs} songs'),
          );
        },
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}
```

### 4. Search Functionality

```dart
class SearchScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _results = [];

  Future<void> _search(String query) async {
    final songs = await ref.read(songsProvider.notifier).search(query);
    final videos = await ref.read(videosProvider.notifier).search(query);
    
    setState(() {
      _results = [...songs, ...videos];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: _search,
          decoration: InputDecoration(hintText: 'Search...'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final item = _results[index];
              return ListTile(title: Text(item.title));
            },
          ),
        ),
      ],
    );
  }
}
```

---

## 🎨 Data Flow

```
User Action (Tap, Swipe, Search)
        ↓
UI Widget (Presentation Layer)
        ↓
Provider (State Management - Riverpod)
        ↓
Repository (Data Layer)
        ↓
Data Source (on_audio_query / File System)
        ↓
Data Models (SongModel / VideoModel)
        ↓
Provider (State Update)
        ↓
UI Widget (Rebuild with new data)
```

---

## ✅ Key Features Implemented

### Navigation
- ✅ PageController-based bottom navigation
- ✅ Smooth page transitions
- ✅ Swipe gesture support
- ✅ 6-tab dashboard in Home

### Data Management
- ✅ Audio scanning with metadata
- ✅ Video scanning from file system
- ✅ Albums, Artists, Playlists support
- ✅ Search functionality

### State Management
- ✅ Riverpod providers
- ✅ Loading states
- ✅ Error handling
- ✅ Automatic UI updates

### Models
- ✅ Comprehensive SongModel
- ✅ Comprehensive VideoModel
- ✅ Utility methods for formatting
- ✅ Immutable with copyWith

---

## 📦 Dependencies Used

```yaml
flutter_riverpod: ^3.2.1      # State management
on_audio_query: ^2.9.0        # Audio scanning
video_player: ^2.10.1         # Video playback
just_audio: ^0.10.5           # Audio playback
audio_service: ^0.18.18       # Background audio
hive: ^2.2.3                  # Local storage
```

---

## 🚀 Next Steps

1. ✅ Navigation system complete
2. ✅ Data layer complete
3. ✅ State management complete
4. ⏳ UI implementation for tabs
5. ⏳ Video player integration
6. ⏳ Playlist management
7. ⏳ Favorites/Library features

---

## 📝 Important Notes

- सभी data operations asynchronous हैं
- Error handling हर provider में built-in है
- Models immutable हैं (copyWith method के साथ)
- Repository pattern का use किया गया है
- Clean separation of concerns
- Scalable architecture

---

## 📚 Additional Resources

- **Architecture Details**: `ARCHITECTURE.md`
- **Usage Examples**: `lib/examples/architecture_usage_examples.dart`
- **Code Documentation**: Inline comments in all files

---

**Created by**: Aura Architecture Team  
**Last Updated**: 2026-02-07
