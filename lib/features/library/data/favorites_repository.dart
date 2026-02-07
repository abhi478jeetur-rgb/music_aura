import 'package:hive_flutter/hive_flutter.dart';
import 'package:aura/core/services/storage_service.dart';

class FavoritesRepository {
  late final Box _box;

  FavoritesRepository() {
    _box = Hive.box(StorageService.favoritesBox);
  }

  /// Returns list of song IDs marked as favorite
  List<int> getFavorites() {
    // Keys in this box are the song IDs (int)
    return _box.keys.cast<int>().toList();
  }

  Future<void> addFavorite(int songId) async {
    await _box.put(songId, true);
  }

  Future<void> removeFavorite(int songId) async {
    await _box.delete(songId);
  }

  bool isFavorite(int songId) {
    return _box.containsKey(songId);
  }
}
