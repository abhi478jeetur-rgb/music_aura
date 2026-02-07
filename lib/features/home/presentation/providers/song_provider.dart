import 'package:aura/core/data/media_repository.dart';
import 'package:aura/core/models/song_model.dart';
import 'package:aura/core/providers/media_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetches the list of songs from MediaRepository.
final songListProvider = FutureProvider<List<AuraSongModel>>((ref) async {
  final repository = ref.watch(mediaRepositoryProvider);
  return await repository.scanAudioFiles();
});
