/// Example: How to use the architecture components
/// 
/// This file demonstrates the usage of:
/// 1. MediaRepository
/// 2. Navigation Controllers
/// 3. Media Providers
/// 4. Data Models

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/providers/media_provider.dart';
import 'package:aura/core/navigation/navigation_controller.dart';
import 'package:aura/core/navigation/tab_controller_manager.dart';

/// Example 1: Using SongsProvider to display songs
class SongsListExample extends ConsumerWidget {
  const SongsListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the songs state
    final songsState = ref.watch(songsProvider);

    // Handle loading state
    if (songsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle error state
    if (songsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${songsState.error}'),
            ElevatedButton(
              onPressed: () {
                // Refresh songs
                ref.read(songsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Display songs
    return ListView.builder(
      itemCount: songsState.songs.length,
      itemBuilder: (context, index) {
        final song = songsState.songs[index];
        return ListTile(
          title: Text(song.title),
          subtitle: Text('${song.artist} • ${song.formattedDuration}'),
          trailing: Text(song.formattedSize),
          onTap: () {
            // Play song
            print('Playing: ${song.title}');
          },
        );
      },
    );
  }
}

/// Example 2: Using VideosProvider to display videos
class VideosListExample extends ConsumerWidget {
  const VideosListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosState = ref.watch(videosProvider);

    if (videosState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (videosState.error != null) {
      return Center(child: Text('Error: ${videosState.error}'));
    }

    return ListView.builder(
      itemCount: videosState.videos.length,
      itemBuilder: (context, index) {
        final video = videosState.videos[index];
        return ListTile(
          title: Text(video.title),
          subtitle: Text(
            '${video.formattedDuration} • ${video.qualityLabel} • ${video.formattedSize}',
          ),
          trailing: Text(video.displayResolution),
          onTap: () {
            // Play video
            print('Playing: ${video.title}');
          },
        );
      },
    );
  }
}

/// Example 3: Using Navigation Controller
class NavigationExample extends ConsumerWidget {
  const NavigationExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationControllerProvider);
    final navigationController = ref.read(navigationControllerProvider.notifier);

    return Column(
      children: [
        Text('Current Screen: ${navigationState.currentIndex}'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => navigationController.navigateToIndex(0),
              child: const Text('Home'),
            ),
            ElevatedButton(
              onPressed: () => navigationController.navigateToIndex(1),
              child: const Text('Search'),
            ),
            ElevatedButton(
              onPressed: () => navigationController.navigateToIndex(2),
              child: const Text('Library'),
            ),
            ElevatedButton(
              onPressed: () => navigationController.navigateToIndex(3),
              child: const Text('Settings'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Example 4: Using Tab Controller Manager
class TabExample extends ConsumerWidget {
  const TabExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabControllerManagerProvider);
    final tabController = ref.read(tabControllerManagerProvider.notifier);

    return Column(
      children: [
        Text('Current Tab: ${tabController.currentTabLabel}'),
        Wrap(
          spacing: 8,
          children: List.generate(
            tabController.tabCount,
            (index) => ChoiceChip(
              label: Text(tabState.tabLabels[index]),
              selected: tabState.currentTabIndex == index,
              onSelected: (selected) {
                if (selected) {
                  tabController.changeTab(index);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Example 5: Loading songs on widget initialization
class AutoLoadSongsExample extends ConsumerStatefulWidget {
  const AutoLoadSongsExample({super.key});

  @override
  ConsumerState<AutoLoadSongsExample> createState() => _AutoLoadSongsExampleState();
}

class _AutoLoadSongsExampleState extends ConsumerState<AutoLoadSongsExample> {
  @override
  void initState() {
    super.initState();
    // Load songs when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(songsProvider.notifier).loadSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final songsState = ref.watch(songsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Songs')),
      body: songsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: songsState.songs.length,
              itemBuilder: (context, index) {
                final song = songsState.songs[index];
                return ListTile(
                  title: Text(song.title),
                  subtitle: Text(song.artist),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(songsProvider.notifier).refresh(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

/// Example 6: Using Albums Provider
class AlbumsExample extends ConsumerWidget {
  const AlbumsExample({super.key});

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
            onTap: () {
              // Navigate to album details
              // Load songs from this album using songsFromAlbumProvider
            },
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

/// Example 7: Using Songs from Album Provider
class AlbumSongsExample extends ConsumerWidget {
  final int albumId;
  
  const AlbumSongsExample({super.key, required this.albumId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsFromAlbumProvider(albumId));

    return songsAsync.when(
      data: (songs) => ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return ListTile(
            leading: Text('${song.trackNumber ?? index + 1}'),
            title: Text(song.title),
            subtitle: Text(song.artist),
            trailing: Text(song.formattedDuration),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

/// Example 8: Search functionality
class SearchExample extends ConsumerStatefulWidget {
  const SearchExample({super.key});

  @override
  ConsumerState<SearchExample> createState() => _SearchExampleState();
}

class _SearchExampleState extends ConsumerState<SearchExample> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Search both songs and videos
    final songs = await ref.read(songsProvider.notifier).search(query);
    final videos = await ref.read(videosProvider.notifier).search(query);

    setState(() {
      _searchResults = [...songs, ...videos];
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search songs and videos...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: _performSearch,
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text(
                        item is app_models.SongModel
                            ? item.artist
                            : 'Video • ${item.formattedDuration}',
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
