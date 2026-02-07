import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/features/library/data/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<int>>(() {
  return FavoritesNotifier();
});

class FavoritesNotifier extends Notifier<List<int>> {
  late final FavoritesRepository _repository;

  @override
  List<int> build() {
    _repository = ref.watch(favoritesRepositoryProvider);
    return _repository.getFavorites();
  }

  Future<void> toggleFavorite(int songId) async {
    if (_repository.isFavorite(songId)) {
      await _repository.removeFavorite(songId);
    } else {
      await _repository.addFavorite(songId);
    }
    state = _repository.getFavorites();
  }

  bool isFavorite(int songId) => state.contains(songId);
}
