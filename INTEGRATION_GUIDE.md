# Quick Integration Guide - Connect the Dots

This guide shows you how to connect the implemented features to the UI.

---

## 1. Connect Artist & Album Tiles to Detail Pages

### Update ArtistTile
**File:** `lib/features/home/presentation/widgets/artist_tile.dart`

```dart
// Add this import at the top:
import 'package:aura/features/home/presentation/pages/artist_page.dart';

// Wrap your existing widget with GestureDetector:
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtistPage(artist: artist),
      ),
    );
  },
  child: // ... your existing widget
)
```

### Update AlbumTile
**File:** `lib/features/home/presentation/widgets/album_tile.dart`

```dart
// Add this import at the top:
import 'package:aura/features/home/presentation/pages/album_page.dart';

// Wrap your existing widget with GestureDetector:
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumPage(album: album),
      ),
    );
  },
  child: // ... your existing widget
)
```

---

## 2. Add "Add to Playlist" to SongTile

### Update SongTile
**File:** `lib/features/home/presentation/widgets/song_tile.dart`

```dart
// Add imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/features/library/presentation/providers/playlists_provider.dart';

// Change SongTile to ConsumerWidget:
class SongTile extends ConsumerWidget {
  final AuraSongModel song;
  
  const SongTile({super.key, required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ... existing code ...
    
    // Add this method:
    void _showAddToPlaylistDialog() {
      final playlists = ref.read(playlistsProvider).playlists;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.deepViolet,
          title: Text(
            'Add to Playlist',
            style: GoogleFonts.outfit(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Create new playlist option
              ListTile(
                leading: Icon(Icons.add, color: AppColors.neonCyan),
                title: Text(
                  'Create New Playlist',
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  _showCreatePlaylistDialog(ref);
                },
              ),
              Divider(color: AppColors.neonCyan.withOpacity(0.2)),
              // List existing playlists
              ...playlists.map((playlist) {
                final isInPlaylist = ref
                    .read(playlistsProvider.notifier)
                    .isSongInPlaylist(playlist.id, song.id);
                
                return ListTile(
                  leading: Icon(
                    isInPlaylist ? Icons.check_circle : Icons.playlist_add,
                    color: isInPlaylist ? AppColors.neonCyan : AppColors.textSecondary,
                  ),
                  title: Text(
                    playlist.name,
                    style: GoogleFonts.inter(color: AppColors.textPrimary),
                  ),
                  onTap: () async {
                    if (!isInPlaylist) {
                      await ref
                          .read(playlistsProvider.notifier)
                          .addSongToPlaylist(playlist.id, song.id);
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      );
    }

    void _showCreatePlaylistDialog(WidgetRef ref) {
      final controller = TextEditingController();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.deepViolet,
          title: Text(
            'New Playlist',
            style: GoogleFonts.outfit(color: AppColors.textPrimary),
          ),
          content: TextField(
            controller: controller,
            style: GoogleFonts.inter(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Playlist name',
              hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final playlist = await ref
                      .read(playlistsProvider.notifier)
                      .createPlaylist(name);
                  
                  if (playlist != null) {
                    await ref
                        .read(playlistsProvider.notifier)
                        .addSongToPlaylist(playlist.id, song.id);
                  }
                }
                Navigator.pop(context);
              },
              child: Text('Create'),
            ),
          ],
        ),
      );
    }

    // Add menu button to your existing widget:
    IconButton(
      icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
      onPressed: _showAddToPlaylistDialog,
    )
  }
}
```

---

## 3. Connect PlayerPage Controls

### Update PlayerPage
**File:** `lib/features/player/presentation/player_page.dart`

```dart
// Add imports:
import 'package:aura/core/services/audio_handler.dart';
import 'package:audio_service/audio_service.dart';

// Inside your ConsumerWidget build method:

// Get audio handler:
final audioHandler = ref.watch(audioHandlerProvider); // You'll need to create this provider

// Shuffle Button:
StreamBuilder<PlaybackState>(
  stream: audioHandler.playbackState,
  builder: (context, snapshot) {
    final isShuffleEnabled = snapshot.data?.shuffleMode == AudioServiceShuffleMode.all;
    
    return IconButton(
      icon: Icon(
        Icons.shuffle,
        color: isShuffleEnabled ? AppColors.neonCyan : AppColors.textSecondary,
      ),
      onPressed: () async {
        if (audioHandler is AuraAudioHandler) {
          await audioHandler.toggleShuffle();
        }
      },
    );
  },
)

// Repeat Button:
StreamBuilder<PlaybackState>(
  stream: audioHandler.playbackState,
  builder: (context, snapshot) {
    final repeatMode = snapshot.data?.repeatMode ?? AudioServiceRepeatMode.none;
    
    IconData iconData;
    Color color;
    
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        iconData = Icons.repeat;
        color = AppColors.textSecondary;
        break;
      case AudioServiceRepeatMode.all:
        iconData = Icons.repeat;
        color = AppColors.neonCyan;
        break;
      case AudioServiceRepeatMode.one:
        iconData = Icons.repeat_one;
        color = AppColors.neonCyan;
        break;
      default:
        iconData = Icons.repeat;
        color = AppColors.textSecondary;
    }
    
    return IconButton(
      icon: Icon(iconData, color: color),
      onPressed: () async {
        if (audioHandler is AuraAudioHandler) {
          await audioHandler.cycleRepeatMode();
        }
      },
    );
  },
)

// Previous Button:
IconButton(
  icon: Icon(Icons.skip_previous, size: 40),
  onPressed: () => audioHandler.skipToPrevious(),
)

// Next Button:
IconButton(
  icon: Icon(Icons.skip_next, size: 40),
  onPressed: () => audioHandler.skipToNext(),
)
```

### Create Audio Handler Provider
**File:** `lib/core/providers/audio_provider.dart` (if not exists) or add to existing:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:aura/core/services/audio_handler.dart';

final audioHandlerProvider = FutureProvider<AudioHandler>((ref) async {
  return await initAudioService();
});
```

---

## 4. Play Songs with Queue

### When user taps a song, play entire list:

```dart
// In SongTile or SongsTab:
Future<void> _playSongWithQueue(
  WidgetRef ref,
  List<AuraSongModel> songs,
  int index,
) async {
  final audioHandler = await ref.read(audioHandlerProvider.future);
  
  // Convert songs to MediaItems:
  final mediaItems = songs.map((song) {
    return MediaItem(
      id: song.id.toString(),
      title: song.title,
      artist: song.artist ?? 'Unknown',
      album: song.album ?? 'Unknown',
      duration: song.duration,
      artUri: song.artworkUri,
      extras: {'url': song.data},
    );
  }).toList();
  
  // Play queue starting at selected song:
  if (audioHandler is AuraAudioHandler) {
    await audioHandler.playQueue(mediaItems, initialIndex: index);
  }
}

// Then in your song tile onTap:
onTap: () => _playSongWithQueue(ref, allSongs, currentIndex),
```

---

## 5. Display Current Queue

### Create Queue Sheet:

```dart
void _showQueueSheet(BuildContext context, AudioHandler audioHandler) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.deepViolet,
    builder: (context) => StreamBuilder<List<MediaItem>>(
      stream: audioHandler.queue,
      builder: (context, snapshot) {
        final queue = snapshot.data ?? [];
        
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Queue (${queue.length})',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: queue.length,
                onReorder: (oldIndex, newIndex) {
                  // Implement reordering if needed
                },
                itemBuilder: (context, index) {
                  final item = queue[index];
                  return ListTile(
                    key: ValueKey(item.id),
                    leading: Icon(Icons.music_note, color: AppColors.neonCyan),
                    title: Text(
                      item.title,
                      style: GoogleFonts.inter(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      item.artist ?? '',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                    onTap: () {
                      audioHandler.skipToQueueItem(index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}
```

---

## Summary Checklist

- [ ] Connect ArtistTile to ArtistPage
- [ ] Connect AlbumTile to AlbumPage
- [ ] Add "Add to Playlist" menu to SongTile
- [ ] Connect Shuffle button in PlayerPage
- [ ] Connect Repeat button in PlayerPage
- [ ] Connect Next/Previous buttons
- [ ] Implement play with queue
- [ ] Show current queue sheet

---

**Estimated Time:** 2-3 hours for all integrations
**Complexity:** Low to Medium
**Impact:** Connects all your production-ready logic to the UI!
