import 'dart:io';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:aura/core/models/song_model.dart' as app_models;
import 'package:aura/core/models/video_model.dart';
import 'package:flutter/foundation.dart';

/// Media Repository - Handles scanning and retrieving both audio and video files
class MediaRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // Supported video extensions
  static const List<String> _videoExtensions = [
    '.mp4',
    '.mkv',
    '.avi',
    '.mov',
    '.wmv',
    '.flv',
    '.webm',
    '.m4v',
    '.3gp',
  ];

  /// Scan and retrieve all audio files
  Future<List<app_models.AuraSongModel>> scanAudioFiles({
    SongSortType sortType = SongSortType.TITLE,
    OrderType orderType = OrderType.ASC_OR_SMALLER,
  }) async {
    if (kIsWeb) return [];
    try {
      final songs = await _audioQuery.querySongs(
        sortType: sortType,
        orderType: orderType,
        uriType: UriType.EXTERNAL,
      );

      if (songs == null) return [];

      return songs
          .map((song) {
            String filePath = song.data;
            return app_models.AuraSongModel(
                id: song.id,
                title: song.title,
                artist: song.artist ?? 'Unknown Artist',
                album: song.album,
                albumArt: null, 
                duration: song.duration ?? 0,
                filePath: filePath,
                size: song.size,
                genre: song.genre,
                year: null,
                composer: song.composer,
                trackNumber: song.track,
                dateAdded: song.dateAdded != null
                    ? DateTime.fromMillisecondsSinceEpoch(song.dateAdded!)
                    : null,
                dateModified: song.dateModified != null
                    ? DateTime.fromMillisecondsSinceEpoch(song.dateModified!)
                    : null,
              );
          })
          .toList();
    } catch (e) {
      print('Error scanning audio files: $e');
      return [];
    }
  }

  /// Get videos using on_audio_query (recommended method)
  /// This method uses on_audio_query which is more efficient and provides better metadata
  Future<List<VideoModel>> getVideos({
    bool sortByDate = false,
  }) async {
    if (kIsWeb) return [];
    try {
      // Query all media files
      final allMedia = await _audioQuery.querySongs(
        sortType: sortByDate ? SongSortType.DATE_ADDED : SongSortType.TITLE,
        orderType: OrderType.DESC_OR_GREATER,
        uriType: UriType.EXTERNAL,
      );

      if (allMedia == null) return [];

      final List<VideoModel> videos = [];
      int videoId = 0;

      // Filter only video files
      for (final media in allMedia) {
        if (_isVideoFile(media.data)) {
          // Extract folder name from path
          final pathParts = media.data.split('/');
          final folderName = pathParts.length > 1 
              ? pathParts[pathParts.length - 2] 
              : 'Unknown';

          videos.add(VideoModel(
            id: videoId++,
            title: media.title,
            filePath: media.data,
            duration: media.duration ?? 0,
            size: media.size,
            dateAdded: media.dateAdded != null
                ? DateTime.fromMillisecondsSinceEpoch(media.dateAdded!)
                : null,
            dateModified: media.dateModified != null
                ? DateTime.fromMillisecondsSinceEpoch(media.dateModified!)
                : null,
            folderName: folderName,
            mimeType: _getMimeType(media.data),
          ));
        }
      }

      return videos;
    } catch (e) {
      print('Error getting videos: $e');
      return [];
    }
  }

  /// Scan and retrieve all video files from device storage (alternative method)
  /// This method scans file system directly - use getVideos() for better performance
  Future<List<VideoModel>> scanVideoFiles() async {
    try {
      final List<VideoModel> videos = [];
      
      // Get all media files (including videos)
      final directories = await _getMediaDirectories();
      
      int videoId = 0;
      for (final directory in directories) {
        final videoFiles = await _scanDirectoryForVideos(directory);
        
        for (final file in videoFiles) {
          final stat = await file.stat();
          final fileName = file.path.split('/').last;
          final title = fileName.replaceAll(RegExp(r'\.[^.]+$'), ''); // Remove extension
          
          videos.add(VideoModel(
            id: videoId++,
            title: title,
            filePath: file.path,
            duration: 0, // Will need video_player to get actual duration
            size: stat.size,
            dateAdded: stat.accessed,
            dateModified: stat.modified,
            folderName: directory.path.split('/').last,
            mimeType: _getMimeType(file.path),
          ));
        }
      }
      
      return videos;
    } catch (e) {
      print('Error scanning video files: $e');
      return [];
    }
  }

  /// Get common media directories on the device
  Future<List<Directory>> _getMediaDirectories() async {
    final List<Directory> directories = [];
    
    try {
      // Common Android media directories
      final possiblePaths = [
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0/Movies',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Videos',
        '/storage/emulated/0/WhatsApp/Media/WhatsApp Video',
      ];
      
      for (final path in possiblePaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          directories.add(dir);
        }
      }
    } catch (e) {
      print('Error getting media directories: $e');
    }
    
    return directories;
  }

  /// Scan a directory for video files recursively
  Future<List<File>> _scanDirectoryForVideos(Directory directory) async {
    final List<File> videoFiles = [];
    
    try {
      await for (final entity in directory.list(recursive: true, followLinks: false)) {
        if (entity is File && _isVideoFile(entity.path)) {
          videoFiles.add(entity);
        }
      }
    } catch (e) {
      print('Error scanning directory ${directory.path}: $e');
    }
    
    return videoFiles;
  }

  /// Check if a file is a video based on extension
  bool _isVideoFile(String path) {
    final extension = path.toLowerCase().substring(path.lastIndexOf('.'));
    return _videoExtensions.contains(extension);
  }

  /// Get MIME type based on file extension
  String _getMimeType(String path) {
    final extension = path.toLowerCase().substring(path.lastIndexOf('.'));
    switch (extension) {
      case '.mp4':
        return 'video/mp4';
      case '.mkv':
        return 'video/x-matroska';
      case '.avi':
        return 'video/x-msvideo';
      case '.mov':
        return 'video/quicktime';
      case '.wmv':
        return 'video/x-ms-wmv';
      case '.flv':
        return 'video/x-flv';
      case '.webm':
        return 'video/webm';
      case '.m4v':
        return 'video/x-m4v';
      case '.3gp':
        return 'video/3gpp';
      default:
        return 'video/unknown';
    }
  }

  /// Get albums
  Future<List<AlbumModel>> getAlbums({
    AlbumSortType sortType = AlbumSortType.ALBUM,
    OrderType orderType = OrderType.ASC_OR_SMALLER,
  }) async {
    try {
      return await _audioQuery.queryAlbums(
        sortType: sortType,
        orderType: orderType,
        uriType: UriType.EXTERNAL,
      );
    } catch (e) {
      print('Error getting albums: $e');
      return [];
    }
  }

  /// Get artists
  Future<List<ArtistModel>> getArtists({
    ArtistSortType sortType = ArtistSortType.ARTIST,
    OrderType orderType = OrderType.ASC_OR_SMALLER,
  }) async {
    try {
      return await _audioQuery.queryArtists(
        sortType: sortType,
        orderType: orderType,
        uriType: UriType.EXTERNAL,
      );
    } catch (e) {
      print('Error getting artists: $e');
      return [];
    }
  }

  /// Get playlists
  Future<List<PlaylistModel>> getPlaylists({
    PlaylistSortType sortType = PlaylistSortType.PLAYLIST,
    OrderType orderType = OrderType.ASC_OR_SMALLER,
  }) async {
    try {
      return await _audioQuery.queryPlaylists(
        sortType: sortType,
        orderType: orderType,
        uriType: UriType.EXTERNAL,
      );
    } catch (e) {
      print('Error getting playlists: $e');
      return [];
    }
  }

  /// Get songs from a specific album
  Future<List<app_models.AuraSongModel>> getSongsFromAlbum(int albumId) async {
    try {
      final songs = await _audioQuery.queryAudiosFrom(
        AudiosFromType.ALBUM_ID,
        albumId,
      );

      return songs
          .map((song) => app_models.AuraSongModel(
                id: song.id,
                title: song.title,
                artist: song.artist ?? 'Unknown Artist',
                album: song.album,
                albumArt: null,
                duration: song.duration ?? 0,
                filePath: song.data,
                size: song.size,
                composer: song.composer,
                trackNumber: song.track,
                dateAdded: song.dateAdded != null
                    ? DateTime.fromMillisecondsSinceEpoch(song.dateAdded!)
                    : null,
                dateModified: song.dateModified != null
                    ? DateTime.fromMillisecondsSinceEpoch(song.dateModified!)
                    : null,
              ))
          .toList();
    } catch (e) {
      print('Error getting songs from album: $e');
      return [];
    }
  }

  /// Get songs from a specific artist
  Future<List<app_models.AuraSongModel>> getSongsFromArtist(int artistId) async {
    try {
      final songs = await _audioQuery.queryAudiosFrom(
        AudiosFromType.ARTIST_ID,
        artistId,
      );

      return songs
          .map((song) => app_models.AuraSongModel(
                id: song.id,
                title: song.title,
                artist: song.artist ?? 'Unknown Artist',
                album: song.album,
                albumArt: null,
                duration: song.duration ?? 0,
                filePath: song.data,
                size: song.size,
                composer: song.composer,
                trackNumber: song.track,
                dateAdded: song.dateAdded != null
                    ? DateTime.fromMillisecondsSinceEpoch(song.dateAdded!)
                    : null,
                dateModified: song.dateModified != null
                    ? DateTime.fromMillisecondsSinceEpoch(song.dateModified!)
                    : null,
              ))
          .toList();
    } catch (e) {
      print('Error getting songs from artist: $e');
      return [];
    }
  }

  /// Get artwork for a song
  Future<dynamic> getArtwork(int id) async {
    try {
      return await _audioQuery.queryArtwork(
        id,
        ArtworkType.AUDIO,
        quality: 100,
      );
    } catch (e) {
      print('Error getting artwork: $e');
      return null;
    }
  }

  /// Search songs by query
  Future<List<app_models.AuraSongModel>> searchSongs(String query) async {
    try {
      final allSongs = await scanAudioFiles();
      return allSongs
          .where((song) =>
              song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.artist.toLowerCase().contains(query.toLowerCase()) ||
              (song.album?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    } catch (e) {
      print('Error searching songs: $e');
      return [];
    }
  }

  /// Search videos by query
  Future<List<VideoModel>> searchVideos(String query) async {
    try {
      final allVideos = await getVideos();
      return allVideos
          .where((video) =>
              video.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error searching videos: $e');
      return [];
    }
  }

  /// Get all media files grouped by folder
  Future<Map<String, List<dynamic>>> getMediaByFolders() async {
    try {
      final songs = await scanAudioFiles();
      final videos = await getVideos();

      final Map<String, List<dynamic>> folderMap = {};

      // Group songs by folder
      for (final song in songs) {
        final folderPath = _extractFolderPath(song.filePath);
        if (!folderMap.containsKey(folderPath)) {
          folderMap[folderPath] = [];
        }
        folderMap[folderPath]!.add(song);
      }

      // Group videos by folder
      for (final video in videos) {
        final folderPath = _extractFolderPath(video.filePath);
        if (!folderMap.containsKey(folderPath)) {
          folderMap[folderPath] = [];
        }
        folderMap[folderPath]!.add(video);
      }

      return folderMap;
    } catch (e) {
      print('Error getting media by folders: $e');
      return {};
    }
  }

  /// Get songs grouped by folder
  Future<Map<String, List<app_models.AuraSongModel>>> getSongsByFolders() async {
    try {
      final songs = await scanAudioFiles();
      final Map<String, List<app_models.AuraSongModel>> folderMap = {};

      for (final song in songs) {
        final folderPath = _extractFolderPath(song.filePath);
        if (!folderMap.containsKey(folderPath)) {
          folderMap[folderPath] = [];
        }
        folderMap[folderPath]!.add(song);
      }

      return folderMap;
    } catch (e) {
      print('Error getting songs by folders: $e');
      return {};
    }
  }

  /// Get videos grouped by folder
  Future<Map<String, List<VideoModel>>> getVideosByFolders() async {
    try {
      final videos = await getVideos();
      final Map<String, List<VideoModel>> folderMap = {};

      for (final video in videos) {
        final folderPath = _extractFolderPath(video.filePath);
        if (!folderMap.containsKey(folderPath)) {
          folderMap[folderPath] = [];
        }
        folderMap[folderPath]!.add(video);
      }

      return folderMap;
    } catch (e) {
      print('Error getting videos by folders: $e');
      return {};
    }
  }

  /// Extract folder path from file path
  String _extractFolderPath(String filePath) {
    final pathParts = filePath.split('/');
    if (pathParts.length > 1) {
      // Remove the file name to get folder path
      pathParts.removeLast();
      return pathParts.join('/');
    }
    return 'Unknown';
  }

  /// Extract folder name from file path
  String _extractFolderName(String filePath) {
    final pathParts = filePath.split('/');
    if (pathParts.length > 1) {
      return pathParts[pathParts.length - 2];
    }
    return 'Unknown';
  }
}
