import 'package:on_audio_query/on_audio_query.dart' as audio;

/// Enhanced Song Model with additional metadata
class AuraSongModel {
  final int id;
  final String title;
  final String artist;
  final String? album;
  final String? albumArt;
  final int duration; // in milliseconds
  final String filePath;
  final int? size; // in bytes
  final String? genre;
  final int? year;
  final String? composer;
  final int? trackNumber;
  final DateTime? dateAdded;
  final DateTime? dateModified;

  AuraSongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.albumArt,
    required this.duration,
    required this.filePath,
    this.size,
    this.genre,
    this.year,
    this.composer,
    this.trackNumber,
    this.dateAdded,
    this.dateModified,
  });

  /// Create AuraSongModel from on_audio_query's SongModel
  factory AuraSongModel.fromAudioQuery(audio.SongModel audioSong) {
    return AuraSongModel(
      id: audioSong.id,
      title: audioSong.title,
      artist: audioSong.artist ?? 'Unknown Artist',
      album: audioSong.album,
      albumArt: null, 
      duration: audioSong.duration ?? 0,
      filePath: audioSong.data,
      size: audioSong.size,
      genre: audioSong.genre,
      year: null,
      composer: audioSong.composer,
      trackNumber: audioSong.track,
      dateAdded: audioSong.dateAdded != null ? DateTime.fromMillisecondsSinceEpoch(audioSong.dateAdded!) : null,
      dateModified: audioSong.dateModified != null ? DateTime.fromMillisecondsSinceEpoch(audioSong.dateModified!) : null,
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'albumArt': albumArt,
      'duration': duration,
      'filePath': filePath,
      'size': size,
      'genre': genre,
      'year': year,
      'composer': composer,
      'trackNumber': trackNumber,
      'dateAdded': dateAdded?.millisecondsSinceEpoch,
      'dateModified': dateModified?.millisecondsSinceEpoch,
    };
  }

  /// Create from Map
  factory AuraSongModel.fromMap(Map<String, dynamic> map) {
    return AuraSongModel(
      id: map['id'] as int,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String?,
      albumArt: map['albumArt'] as String?,
      duration: map['duration'] as int,
      filePath: map['filePath'] as String,
      size: map['size'] as int?,
      genre: map['genre'] as String?,
      year: map['year'] as int?,
      composer: map['composer'] as String?,
      trackNumber: map['trackNumber'] as int?,
      dateAdded: map['dateAdded'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateAdded'] as int)
          : null,
      dateModified: map['dateModified'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateModified'] as int)
          : null,
    );
  }

  /// Get formatted duration (e.g., "3:45")
  String get formattedDuration {
    final minutes = duration ~/ 60000;
    final seconds = (duration % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted size (e.g., "3.5 MB")
  String get formattedSize {
    if (size == null) return 'Unknown';
    final mb = size! / (1024 * 1024);
    return '${mb.toStringAsFixed(2)} MB';
  }

  /// Copy with method for immutability
  AuraSongModel copyWith({
    int? id,
    String? title,
    String? artist,
    String? album,
    String? albumArt,
    int? duration,
    String? filePath,
    int? size,
    String? genre,
    int? year,
    String? composer,
    int? trackNumber,
    DateTime? dateAdded,
    DateTime? dateModified,
  }) {
    return AuraSongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArt: albumArt ?? this.albumArt,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      size: size ?? this.size,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      composer: composer ?? this.composer,
      trackNumber: trackNumber ?? this.trackNumber,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuraSongModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
