import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/data/media_repository.dart';
import 'package:aura/core/models/song_model.dart';
import 'package:aura/core/models/video_model.dart';
import 'package:aura/core/providers/media_provider.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio;

/// Search Result State
class SearchResultState {
  final List<AuraSongModel> songs;
  final List<audio.ArtistModel> artists;
  final List<audio.AlbumModel> albums;
  final List<VideoModel> videos;
  final bool isSearching;
  final String query;
  
  SearchResultState({
    required this.songs,
    required this.artists,
    required this.albums,
    required this.videos,
    required this.isSearching,
    required this.query,
  });
  
  SearchResultState copyWith({
    List<AuraSongModel>? songs,
    List<audio.ArtistModel>? artists,
    List<audio.AlbumModel>? albums,
    List<VideoModel>? videos,
    bool? isSearching,
    String? query,
  }) {
    return SearchResultState(
      songs: songs ?? this.songs,
      artists: artists ?? this.artists,
      albums: albums ?? this.albums,
      videos: videos ?? this.videos,
      isSearching: isSearching ?? this.isSearching,
      query: query ?? this.query,
    );
  }
  
  bool get hasResults => 
    songs.isNotEmpty || 
    artists.isNotEmpty || 
    albums.isNotEmpty || 
    videos.isNotEmpty;
}

/// Search Notifier - Handles real-time search across all media types
class SearchNotifier extends Notifier<SearchResultState> {
  late final MediaRepository _repository;
  
  @override
  SearchResultState build() {
    _repository = ref.watch(mediaRepositoryProvider);
    return SearchResultState(
      songs: [],
      artists: [],
      albums: [],
      videos: [],
      isSearching: false,
      query: '',
    );
  }
  
  /// Perform real-time search across all media
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      // Clear results if query is empty
      state = SearchResultState(
        songs: [],
        artists: [],
        albums: [],
        videos: [],
        isSearching: false,
        query: '',
      );
      return;
    }
    
    state = state.copyWith(isSearching: true, query: query);
    
    try {
      final lowerQuery = query.toLowerCase();
      
      // Search songs
      final songs = await _repository.searchSongs(query);
      
      // Search videos
      final videos = await _repository.searchVideos(query);
      
      // Search artists
      final allArtists = await _repository.getArtists();
      final filteredArtists = allArtists.where((artist) {
        return artist.artist.toLowerCase().contains(lowerQuery);
      }).toList();
      
      // Search albums
      final allAlbums = await _repository.getAlbums();
      final filteredAlbums = allAlbums.where((album) {
        return album.album.toLowerCase().contains(lowerQuery);
      }).toList();
      
      state = state.copyWith(
        songs: songs,
        artists: filteredArtists,
        albums: filteredAlbums,
        videos: videos,
        isSearching: false,
      );
    } catch (e) {
      print('Search error: $e');
      state = state.copyWith(isSearching: false);
    }
  }
  
  /// Clear search results
  void clear() {
    state = SearchResultState(
      songs: [],
      artists: [],
      albums: [],
      videos: [],
      isSearching: false,
      query: '',
    );
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchResultState>(() {
  return SearchNotifier();
});
