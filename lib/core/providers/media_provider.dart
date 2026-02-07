import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/data/media_repository.dart';
import 'package:aura/core/models/song_model.dart';
import 'package:aura/core/models/video_model.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio;

/// Media Repository Provider
final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository();
});

/// Songs State
class SongsState {
  final List<AuraSongModel> songs;
  final bool isLoading;
  final String? error;

  SongsState({
    required this.songs,
    required this.isLoading,
    this.error,
  });

  SongsState copyWith({
    List<AuraSongModel>? songs,
    bool? isLoading,
    String? error,
  }) {
    return SongsState(
      songs: songs ?? this.songs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Songs Provider - Manages all songs
class SongsNotifier extends Notifier<SongsState> {
  late final MediaRepository _repository;

  @override
  SongsState build() {
    _repository = ref.watch(mediaRepositoryProvider);
    return SongsState(songs: [], isLoading: false);
  }

  /// Load all songs
  Future<void> loadSongs({
    audio.SongSortType sortType = audio.SongSortType.TITLE,
    audio.OrderType orderType = audio.OrderType.ASC_OR_SMALLER,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final songs = await _repository.scanAudioFiles(
        sortType: sortType,
        orderType: orderType,
      );
      state = state.copyWith(songs: songs, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load songs: $e',
      );
    }
  }

  /// Refresh songs
  Future<void> refresh() async {
    await loadSongs();
  }

  /// Search songs
  Future<List<AuraSongModel>> search(String query) async {
    return await _repository.searchSongs(query);
  }
}

final songsProvider = NotifierProvider<SongsNotifier, SongsState>(() {
  return SongsNotifier();
});

/// Videos State
class VideosState {
  final List<VideoModel> videos;
  final bool isLoading;
  final String? error;

  VideosState({
    required this.videos,
    required this.isLoading,
    this.error,
  });

  VideosState copyWith({
    List<VideoModel>? videos,
    bool? isLoading,
    String? error,
  }) {
    return VideosState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Videos Provider - Manages all videos
class VideosNotifier extends Notifier<VideosState> {
  late final MediaRepository _repository;

  @override
  VideosState build() {
    _repository = ref.watch(mediaRepositoryProvider);
    return VideosState(videos: [], isLoading: false);
  }

  /// Load all videos
  Future<void> loadVideos({bool sortByDate = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Use getVideos() which is more efficient and provides better metadata
      final videos = await _repository.getVideos(sortByDate: sortByDate);
      state = state.copyWith(videos: videos, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load videos: $e',
      );
    }
  }

  /// Refresh videos
  Future<void> refresh() async {
    await loadVideos();
  }

  /// Search videos
  Future<List<VideoModel>> search(String query) async {
    return await _repository.searchVideos(query);
  }
}

final videosProvider = NotifierProvider<VideosNotifier, VideosState>(() {
  return VideosNotifier();
});

/// Albums Provider
final albumsProvider = FutureProvider<List<audio.AlbumModel>>((ref) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return await repository.getAlbums();
});

/// Artists Provider
final artistsProvider = FutureProvider<List<audio.ArtistModel>>((ref) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return await repository.getArtists();
});

/// Playlists Provider
final playlistsProvider = FutureProvider<List<audio.PlaylistModel>>((ref) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return await repository.getPlaylists();
});

/// Songs from Album Provider
final songsFromAlbumProvider = FutureProvider.family<List<AuraSongModel>, int>((ref, albumId) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return await repository.getSongsFromAlbum(albumId);
});

/// Songs from Artist Provider
final songsFromArtistProvider = FutureProvider.family<List<AuraSongModel>, int>((ref, artistId) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return await repository.getSongsFromArtist(artistId);
});
