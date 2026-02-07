# 🚀 Aura App - Quick Reference Guide

## 📚 Documentation Files

| File | Purpose | Language |
|------|---------|----------|
| `IMPLEMENTATION_SUMMARY.md` | Complete implementation summary | English |
| `ARCHITECTURE_README.md` | Full usage guide | Hindi |
| `ARCHITECTURE.md` | Technical architecture details | English |
| `ARCHITECTURE_DIAGRAM.md` | Visual diagrams | English |
| `lib/examples/architecture_usage_examples.dart` | Code examples | Dart |

---

## 🗂️ Quick File Reference

### Navigation
```
lib/core/navigation/
├── navigation_controller.dart      # Bottom navigation (4 screens)
└── tab_controller_manager.dart     # Home tabs (6 tabs)
```

### Data Models
```
lib/core/models/
├── song_model.dart                 # Audio file model
└── video_model.dart                # Video file model
```

### Data Layer
```
lib/core/data/
└── media_repository.dart           # Audio + Video scanning
```

### State Management
```
lib/core/providers/
└── media_provider.dart             # All media providers
```

---

## ⚡ Quick Start

### 1. Load Songs
```dart
// Initialize
ref.read(songsProvider.notifier).loadSongs();

// Watch state
final songsState = ref.watch(songsProvider);

// Use data
if (!songsState.isLoading && songsState.error == null) {
  final songs = songsState.songs;
  // Display songs
}
```

### 2. Load Videos
```dart
ref.read(videosProvider.notifier).loadVideos();
final videosState = ref.watch(videosProvider);
```

### 3. Navigate
```dart
// Bottom navigation
ref.read(navigationControllerProvider.notifier).navigateToIndex(2);

// Tab navigation
ref.read(tabControllerManagerProvider.notifier).changeTab(1);
```

### 4. Search
```dart
final songs = await ref.read(songsProvider.notifier).search("query");
final videos = await ref.read(videosProvider.notifier).search("query");
```

---

## 📋 Provider Cheat Sheet

| Provider | Type | Purpose |
|----------|------|---------|
| `navigationControllerProvider` | StateNotifier | Bottom navigation state |
| `tabControllerManagerProvider` | StateNotifier | Home tabs state |
| `mediaRepositoryProvider` | Provider | Repository singleton |
| `songsProvider` | StateNotifier | Songs state + methods |
| `videosProvider` | StateNotifier | Videos state + methods |
| `albumsProvider` | FutureProvider | Albums list |
| `artistsProvider` | FutureProvider | Artists list |
| `playlistsProvider` | FutureProvider | Playlists list |
| `songsFromAlbumProvider(id)` | FutureProvider.family | Album songs |
| `songsFromArtistProvider(id)` | FutureProvider.family | Artist songs |

---

## 🎯 Common Patterns

### Pattern 1: Display List with Loading
```dart
final state = ref.watch(songsProvider);

if (state.isLoading) return CircularProgressIndicator();
if (state.error != null) return Text('Error: ${state.error}');

return ListView.builder(
  itemCount: state.songs.length,
  itemBuilder: (context, index) {
    final song = state.songs[index];
    return ListTile(title: Text(song.title));
  },
);
```

### Pattern 2: FutureProvider with AsyncValue
```dart
final albumsAsync = ref.watch(albumsProvider);

return albumsAsync.when(
  data: (albums) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, _) => Text('Error: $error'),
);
```

### Pattern 3: Load on Init
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(songsProvider.notifier).loadSongs();
  });
}
```

---

## 🔧 Utility Methods

### SongModel
```dart
song.formattedDuration    // "3:45"
song.formattedSize        // "3.5 MB"
song.toMap()              // Convert to Map
SongModel.fromMap(map)    // Create from Map
```

### VideoModel
```dart
video.formattedDuration   // "1:23:45"
video.formattedSize       // "125.5 MB"
video.qualityLabel        // "HD", "Full HD", "4K"
video.displayResolution   // "1920x1080"
```

---

## 📱 Screen Structure

```
MainScreen (PageView)
├── Home (TabController)
│   ├── Songs
│   ├── Videos
│   ├── Playlists
│   ├── Folders
│   ├── Artists
│   └── Albums
├── Search
├── Library
└── Settings
```

---

## 🎨 Next Steps

1. ✅ Architecture complete
2. ⏳ Implement UI for tabs
3. ⏳ Add video player
4. ⏳ Implement playlist management
5. ⏳ Add favorites feature

---

## 💡 Tips

- Always handle loading and error states
- Use `ref.watch()` in build method
- Use `ref.read()` in callbacks
- Models are immutable, use `copyWith()`
- Repository methods are async
- Providers auto-update UI

---

## 📞 Quick Help

**Need examples?** → `lib/examples/architecture_usage_examples.dart`  
**Need diagrams?** → `ARCHITECTURE_DIAGRAM.md`  
**Need Hindi guide?** → `ARCHITECTURE_README.md`  
**Need details?** → `ARCHITECTURE.md`  
**Need summary?** → `IMPLEMENTATION_SUMMARY.md`

---

**Status**: ✅ Ready for UI Development  
**Last Updated**: 2026-02-07
