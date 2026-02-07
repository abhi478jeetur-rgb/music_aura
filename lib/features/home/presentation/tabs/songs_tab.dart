import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/home/presentation/providers/song_provider.dart';
import 'package:aura/features/home/presentation/widgets/song_tile.dart';
import 'package:aura/features/player/presentation/player_page.dart';
import 'package:aura/core/providers/audio_provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongsTab extends ConsumerWidget {
  const SongsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songListAsync = ref.watch(songListProvider);

    return songListAsync.when(
      data: (songs) {
        if (songs.isEmpty) {
          return const Center(child: Text("No songs found on device."));
        }
        return ListView.builder(
          itemCount: songs.length,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final song = songs[index];
            return SongTile(
              song: song,
              onTap: () async {
                final audioHandler = ref.read(audioHandlerProvider);
                final mediaItem = MediaItem(
                  id: song.id.toString(),
                  album: song.album,
                  title: song.title,
                  artist: song.artist,
                  duration: Duration(milliseconds: song.duration ?? 0),
                  artUri: Uri.parse("content://media/external/audio/media/${song.id}/albumart"),
                  extras: {'url': song.filePath},
                );

                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PlayerPage(song: song)),
                );

                await audioHandler.playMediaItem(mediaItem);
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonCyan)),
      error: (err, stack) => Center(child: Text("Error: $err")),
    );
  }
}
