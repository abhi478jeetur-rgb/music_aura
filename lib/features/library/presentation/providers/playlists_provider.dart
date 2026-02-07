import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/features/library/data/playlists_repository.dart';
import 'package:aura/core/data/media_repository.dart';
import 'package:aura/core/models/song_model.dart';
import 'package:aura/core/providers/media_provider.dart';

/// Playlist Repository Provider
final playlistsRepositoryProvider = Provider<PlaylistsRepository>((ref) {
  return PlaylistsRepository();
});

/// Playlists State
class PlaylistsState {
  final List<PlaylistModel> playlists;
  final bool isLoading;
  final String? error;
  
  PlaylistsState({
    required this.playlists,
    required this.isLoading,
    this.error,
  });
  
  PlaylistsState copyWith({
    List<PlaylistModel>? playlists,
    bool? isLoading,
    String? error,
  }) {
    return PlaylistsState(
      playlists: playlists ?? this.playlists,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Playlists Notifier - Manages all playlists
class PlaylistsNotifier extends Notifier<PlaylistsState> {
  late final PlaylistsRepository _repository;
  
  @override
  PlaylistsState build() {
    _repository = ref.watch(playlistsRepositoryProvider);
    loadPlaylists();
    return PlaylistsState(playlists: [], isLoading: true);
  }
  
  /// Load all playlists
  void loadPlaylists() {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final playlists = _repository.getAllPlaylists();
      state = state.copyWith(playlists: playlists, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load playlists: $e',
      );
    }
  }
  
  /// Create a new playlist
  Future<PlaylistModel?> createPlaylist(String name) async {
    if (name.trim().isEmpty) return null;
    
    try {
      final playlist = await _repository.createPlaylist(name.trim());
      loadPlaylists(); // Refresh the list
      return playlist;
    } catch (e) {
      state = state.copyWith(error: 'Failed to create playlist: $e');
      return null;
    }
  }
  
  /// Rename a playlist
  Future<void> renamePlaylist(String id, String newName) async {
    if (newName.trim().isEmpty) return;
    
    try {
      await _repository.renamePlaylist(id, newName.trim());
      loadPlaylists(); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: 'Failed to rename playlist: $e');
    }
  }
  
  /// Delete a playlist
  Future<void> deletePlaylist(String id) async {
    try {
      await _repository.deletePlaylist(id);
      loadPlaylists(); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete playlist: $e');
    }
  }
  
  /// Add a song to a playlist
  Future<void> addSongToPlaylist(String playlistId, int songId) async {
    try {
      await _repository.addSongToPlaylist(playlistId, songId);
      loadPlaylists(); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: 'Failed to add song to playlist: $e');
    }
  }
  
  /// Remove a song from a playlist
  Future<void> removeSongFromPlaylist(String playlistId, int songId) async {
    try {
      await _repository.removeSongFromPlaylist(playlistId, songId);
      loadPlaylists(); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove song from playlist: $e');
    }
  }
  
  /// Reorder songs in a playlist
  Future<void> reorderSongs(String playlistId, int oldIndex, int newIndex) async {
    try {
      await _repository.reorderSongs(playlistId, oldIndex, newIndex);
      loadPlaylists(); // Refresh the list
    } catch (e) {
      state = state.copyWith(error: 'Failed to reorder songs: $e');
    }
  }
  
  /// Check if a song is in a playlist
  bool isSongInPlaylist(String playlistId, int songId) {
    return _repository.isSongInPlaylist(playlistId, songId);
  }
}

final playlistsProvider = NotifierProvider<PlaylistsNotifier, PlaylistsState>(() {
  return PlaylistsNotifier();
});

/// Provider to get songs from a specific playlist
final playlistSongsProvider = FutureProvider.family<List<AuraSongModel>, String>((ref, playlistId) async {
  final playlistsRepo = ref.watch(playlistsRepositoryProvider);
  final mediaRepo = ref.watch(mediaRepositoryProvider);
  
  final playlist = playlistsRepo.getPlaylist(playlistId);
  if (playlist == null) return [];
  
  // Get all songs
  final allSongs = await mediaRepo.scanAudioFiles();
  
  // Filter to only songs in this playlist, maintaining order
  final playlistSongs = <AuraSongModel>[];
  for (final songId in playlist.songIds) {
    final song = allSongs.firstWhere(
      (s) => s.id == songId,
      orElse: () => allSongs.first, // Fallback, though this shouldn't happen
    );
    if (song.id == songId) {
      playlistSongs.add(song);
    }
  }
  
  return playlistSongs;
});
