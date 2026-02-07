import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/data/media_repository.dart';
import 'package:aura/core/models/folder_model.dart';
import 'package:aura/core/models/song_model.dart';
import 'package:aura/core/models/video_model.dart';
import 'package:aura/core/providers/media_provider.dart';

/// Folders State
class FoldersState {
  final List<FolderModel> folders;
  final bool isLoading;
  final String? error;

  FoldersState({
    required this.folders,
    required this.isLoading,
    this.error,
  });

  FoldersState copyWith({
    List<FolderModel>? folders,
    bool? isLoading,
    String? error,
  }) {
    return FoldersState(
      folders: folders ?? this.folders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Folders Provider - Manages folders with grouped media
class FoldersNotifier extends Notifier<FoldersState> {
  late final MediaRepository _repository;

  @override
  FoldersState build() {
    _repository = ref.watch(mediaRepositoryProvider);
    return FoldersState(folders: [], isLoading: false);
  }

  /// Load all folders with their media files
  Future<void> loadFolders() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get songs and videos grouped by folders
      final songsByFolder = await _repository.getSongsByFolders();
      final videosByFolder = await _repository.getVideosByFolders();

      // Combine all folder paths
      final allFolderPaths = <String>{
        ...songsByFolder.keys,
        ...videosByFolder.keys,
      };

      // Create FolderModel for each folder
      final folders = <FolderModel>[];
      for (final folderPath in allFolderPaths) {
        final songs = songsByFolder[folderPath] ?? [];
        final videos = videosByFolder[folderPath] ?? [];

        // Extract folder name from path
        final folderName = _extractFolderName(folderPath);

        folders.add(FolderModel(
          folderName: folderName,
          folderPath: folderPath,
          songs: songs,
          videos: videos,
        ));
      }

      // Sort folders by name
      folders.sort((a, b) => a.folderName.compareTo(b.folderName));

      state = state.copyWith(folders: folders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load folders: $e',
      );
    }
  }

  /// Refresh folders
  Future<void> refresh() async {
    await loadFolders();
  }

  /// Get folder by path
  FolderModel? getFolderByPath(String path) {
    try {
      return state.folders.firstWhere((folder) => folder.folderPath == path);
    } catch (e) {
      return null;
    }
  }

  /// Search folders by name
  List<FolderModel> searchFolders(String query) {
    if (query.isEmpty) return state.folders;
    
    return state.folders
        .where((folder) =>
            folder.folderName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Extract folder name from path
  String _extractFolderName(String folderPath) {
    final pathParts = folderPath.split('/');
    if (pathParts.isNotEmpty) {
      return pathParts.last.isEmpty 
          ? (pathParts.length > 1 ? pathParts[pathParts.length - 2] : 'Unknown')
          : pathParts.last;
    }
    return 'Unknown';
  }
}

/// Provider for Folders
final foldersProvider =
    NotifierProvider<FoldersNotifier, FoldersState>(() {
  return FoldersNotifier();
});

/// Provider to get media from a specific folder
final folderMediaProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, folderPath) async {
  final repository = ref.watch(mediaRepositoryProvider);
  
  final allSongs = await repository.scanAudioFiles();
  final allVideos = await repository.getVideos();

  final songs = allSongs
      .where((song) => song.filePath.startsWith(folderPath))
      .toList();
  
  final videos = allVideos
      .where((video) => video.filePath.startsWith(folderPath))
      .toList();

  return {
    'songs': songs,
    'videos': videos,
  };
});
