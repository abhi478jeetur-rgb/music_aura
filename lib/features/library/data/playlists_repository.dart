import 'package:hive_flutter/hive_flutter.dart';
import 'package:aura/core/services/storage_service.dart';

/// Playlist Model for Hive storage
class PlaylistModel {
  final String id;
  final String name;
  final List<int> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  PlaylistModel({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'songIds': songIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  
  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'],
      name: json['name'],
      songIds: List<int>.from(json['songIds']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  
  PlaylistModel copyWith({
    String? id,
    String? name,
    List<int>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Playlists Repository - Handles all playlist CRUD operations
class PlaylistsRepository {
  late final Box _box;
  
  PlaylistsRepository() {
    _box = Hive.box(StorageService.playlistsBox);
  }
  
  /// Get all playlists
  List<PlaylistModel> getAllPlaylists() {
    try {
      final playlists = _box.values
          .map((json) => PlaylistModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      
      // Sort by updated date (most recent first)
      playlists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return playlists;
    } catch (e) {
      print('Error getting playlists: $e');
      return [];
    }
  }
  
  /// Get a specific playlist by ID
  PlaylistModel? getPlaylist(String id) {
    try {
      final json = _box.get(id);
      if (json == null) return null;
      return PlaylistModel.fromJson(Map<String, dynamic>.from(json));
    } catch (e) {
      print('Error getting playlist: $e');
      return null;
    }
  }
  
  /// Create a new playlist
  Future<PlaylistModel> createPlaylist(String name) async {
    final now = DateTime.now();
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: now,
      updatedAt: now,
    );
    
    await _box.put(playlist.id, playlist.toJson());
    return playlist;
  }
  
  /// Rename a playlist
  Future<void> renamePlaylist(String id, String newName) async {
    final playlist = getPlaylist(id);
    if (playlist == null) return;
    
    final updated = playlist.copyWith(
      name: newName,
      updatedAt: DateTime.now(),
    );
    
    await _box.put(id, updated.toJson());
  }
  
  /// Delete a playlist
  Future<void> deletePlaylist(String id) async {
    await _box.delete(id);
  }
  
  /// Add a song to a playlist
  Future<void> addSongToPlaylist(String playlistId, int songId) async {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return;
    
    // Check if song already exists
    if (playlist.songIds.contains(songId)) return;
    
    final updatedSongIds = [...playlist.songIds, songId];
    final updated = playlist.copyWith(
      songIds: updatedSongIds,
      updatedAt: DateTime.now(),
    );
    
    await _box.put(playlistId, updated.toJson());
  }
  
  /// Remove a song from a playlist
  Future<void> removeSongFromPlaylist(String playlistId, int songId) async {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return;
    
    final updatedSongIds = playlist.songIds.where((id) => id != songId).toList();
    final updated = playlist.copyWith(
      songIds: updatedSongIds,
      updatedAt: DateTime.now(),
    );
    
    await _box.put(playlistId, updated.toJson());
  }
  
  /// Reorder songs in a playlist
  Future<void> reorderSongs(String playlistId, int oldIndex, int newIndex) async {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return;
    
    final songIds = [...playlist.songIds];
    final song = songIds.removeAt(oldIndex);
    songIds.insert(newIndex, song);
    
    final updated = playlist.copyWith(
      songIds: songIds,
      updatedAt: DateTime.now(),
    );
    
    await _box.put(playlistId, updated.toJson());
  }
  
  /// Check if a song is in a specific playlist
  bool isSongInPlaylist(String playlistId, int songId) {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return false;
    return playlist.songIds.contains(songId);
  }
  
  /// Get all playlists containing a specific song
  List<PlaylistModel> getPlaylistsContainingSong(int songId) {
    final allPlaylists = getAllPlaylists();
    return allPlaylists.where((playlist) => playlist.songIds.contains(songId)).toList();
  }
}
