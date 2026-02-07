/// Video Model for managing video files
class VideoModel {
  final int id;
  final String title;
  final String filePath;
  final int duration; // in milliseconds
  final String? thumbnail;
  final int? size; // in bytes
  final int? width;
  final int? height;
  final String? resolution; // e.g., "1920x1080"
  final DateTime? dateAdded;
  final DateTime? dateModified;
  final String? folderName;
  final String? mimeType;

  VideoModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.duration,
    this.thumbnail,
    this.size,
    this.width,
    this.height,
    this.resolution,
    this.dateAdded,
    this.dateModified,
    this.folderName,
    this.mimeType,
  });

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'duration': duration,
      'thumbnail': thumbnail,
      'size': size,
      'width': width,
      'height': height,
      'resolution': resolution,
      'dateAdded': dateAdded?.millisecondsSinceEpoch,
      'dateModified': dateModified?.millisecondsSinceEpoch,
      'folderName': folderName,
      'mimeType': mimeType,
    };
  }

  /// Create from Map
  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] as int,
      title: map['title'] as String,
      filePath: map['filePath'] as String,
      duration: map['duration'] as int,
      thumbnail: map['thumbnail'] as String?,
      size: map['size'] as int?,
      width: map['width'] as int?,
      height: map['height'] as int?,
      resolution: map['resolution'] as String?,
      dateAdded: map['dateAdded'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateAdded'] as int)
          : null,
      dateModified: map['dateModified'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateModified'] as int)
          : null,
      folderName: map['folderName'] as String?,
      mimeType: map['mimeType'] as String?,
    );
  }

  /// Get formatted duration (e.g., "1:23:45" or "3:45")
  String get formattedDuration {
    final hours = duration ~/ 3600000;
    final minutes = (duration % 3600000) ~/ 60000;
    final seconds = (duration % 60000) ~/ 1000;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get formatted size (e.g., "125.5 MB")
  String get formattedSize {
    if (size == null) return 'Unknown';
    final mb = size! / (1024 * 1024);
    if (mb >= 1024) {
      final gb = mb / 1024;
      return '${gb.toStringAsFixed(2)} GB';
    }
    return '${mb.toStringAsFixed(2)} MB';
  }

  /// Get display resolution
  String get displayResolution {
    if (resolution != null) return resolution!;
    if (width != null && height != null) return '${width}x$height';
    return 'Unknown';
  }

  /// Get quality label (HD, Full HD, 4K, etc.)
  String get qualityLabel {
    if (height == null) return 'SD';
    if (height! >= 2160) return '4K';
    if (height! >= 1080) return 'Full HD';
    if (height! >= 720) return 'HD';
    return 'SD';
  }

  /// Copy with method for immutability
  VideoModel copyWith({
    int? id,
    String? title,
    String? filePath,
    int? duration,
    String? thumbnail,
    int? size,
    int? width,
    int? height,
    String? resolution,
    DateTime? dateAdded,
    DateTime? dateModified,
    String? folderName,
    String? mimeType,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      thumbnail: thumbnail ?? this.thumbnail,
      size: size ?? this.size,
      width: width ?? this.width,
      height: height ?? this.height,
      resolution: resolution ?? this.resolution,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      folderName: folderName ?? this.folderName,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
