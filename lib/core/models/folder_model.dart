import 'package:aura/core/models/song_model.dart';
import 'package:aura/core/models/video_model.dart';

/// Folder Model - Represents a folder containing media files
class FolderModel {
  final String folderName;
  final String folderPath;
  final List<AuraSongModel> songs;
  final List<VideoModel> videos;
  final int totalItems;
  final DateTime? lastModified;

  FolderModel({
    required this.folderName,
    required this.folderPath,
    required this.songs,
    required this.videos,
    DateTime? lastModified,
  })  : totalItems = songs.length + videos.length,
        lastModified = lastModified ?? _getLatestModifiedDate(songs, videos);

  /// Get the latest modified date from all media in folder
  static DateTime? _getLatestModifiedDate(
    List<AuraSongModel> songs,
    List<VideoModel> videos,
  ) {
    DateTime? latest;

    for (final song in songs) {
      if (song.dateModified != null) {
        if (latest == null || song.dateModified!.isAfter(latest)) {
          latest = song.dateModified;
        }
      }
    }

    for (final video in videos) {
      if (video.dateModified != null) {
        if (latest == null || video.dateModified!.isAfter(latest)) {
          latest = video.dateModified;
        }
      }
    }

    return latest;
  }

  /// Get total duration of all media in folder (in milliseconds)
  int get totalDuration {
    int total = 0;
    for (final song in songs) {
      total += song.duration;
    }
    for (final video in videos) {
      total += video.duration;
    }
    return total;
  }

  /// Get formatted total duration
  String get formattedTotalDuration {
    final hours = totalDuration ~/ 3600000;
    final minutes = (totalDuration % 3600000) ~/ 60000;

    if (hours > 0) {
      return '$hours hr ${minutes} min';
    } else {
      return '$minutes min';
    }
  }

  /// Get total size of all media in folder (in bytes)
  int get totalSize {
    int total = 0;
    for (final song in songs) {
      total += song.size ?? 0;
    }
    for (final video in videos) {
      total += video.size ?? 0;
    }
    return total;
  }

  /// Get formatted total size
  String get formattedTotalSize {
    final mb = totalSize / (1024 * 1024);
    if (mb >= 1024) {
      final gb = mb / 1024;
      return '${gb.toStringAsFixed(2)} GB';
    }
    return '${mb.toStringAsFixed(2)} MB';
  }

  /// Get count summary (e.g., "5 songs, 3 videos")
  String get itemCountSummary {
    final parts = <String>[];
    if (songs.isNotEmpty) {
      parts.add('${songs.length} ${songs.length == 1 ? 'song' : 'songs'}');
    }
    if (videos.isNotEmpty) {
      parts.add('${videos.length} ${videos.length == 1 ? 'video' : 'videos'}');
    }
    return parts.isEmpty ? 'Empty folder' : parts.join(', ');
  }

  /// Copy with method
  FolderModel copyWith({
    String? folderName,
    String? folderPath,
    List<AuraSongModel>? songs,
    List<VideoModel>? videos,
    DateTime? lastModified,
  }) {
    return FolderModel(
      folderName: folderName ?? this.folderName,
      folderPath: folderPath ?? this.folderPath,
      songs: songs ?? this.songs,
      videos: videos ?? this.videos,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FolderModel && other.folderPath == folderPath;
  }

  @override
  int get hashCode => folderPath.hashCode;
}
