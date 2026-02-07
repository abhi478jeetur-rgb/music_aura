import 'package:on_audio_query/on_audio_query.dart';

class AudioRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// Fetches all songs from external storage.
  /// Ensure permission is granted before calling this.
  Future<List<SongModel>> getSongs() async {
    return await _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }
}
