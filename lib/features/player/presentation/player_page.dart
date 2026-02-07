import 'package:audio_service/audio_service.dart';
import 'package:aura/core/models/song_model.dart';
import 'package:aura/core/presentation/widgets/glass_container.dart';
import 'package:aura/core/providers/audio_provider.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerPage extends ConsumerWidget {
  final AuraSongModel song;

  const PlayerPage({super.key, required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Now Playing", 
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          )),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Album Art
              Hero(
                tag: 'artwork_${song.id}',
                child: GlassContainer(
                  height: 320,
                  width: 320,
                  blur: 20,
                  opacity: 0.1,
                  borderRadius: BorderRadius.circular(40),
                  padding: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkHeight: 280,
                      artworkWidth: 280,
                      artworkFit: BoxFit.cover,
                      nullArtworkWidget: Container(
                        color: AppColors.deepViolet,
                        child: const Icon(Icons.music_note,
                            size: 100, color: AppColors.neonCyan),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Song Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      song.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      song.artist ?? "Unknown Artist",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Progress Bar (StreamBuilder could be used here for smoother updates)
              StreamBuilder<Duration>(
                stream: AudioService.position,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = Duration(milliseconds: song.duration ?? 0);
                  double percent = 0.0;
                  if (duration.inMilliseconds > 0) {
                    percent = position.inMilliseconds / duration.inMilliseconds;
                    if (percent > 1.0) percent = 1.0;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        LinearPercentIndicator(
                          percent: percent,
                          backgroundColor: Colors.white10,
                          progressColor: AppColors.neonCyan,
                          barRadius: const Radius.circular(10),
                          lineHeight: 6,
                          animation: true,
                          animateFromLastPercent: true,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(position), style: const TextStyle(color: Colors.white54)),
                            Text(_formatDuration(duration), style: const TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {}, // Shuffle
                    icon: const Icon(Icons.shuffle, color: Colors.white54),
                  ),
                  IconButton(
                    onPressed: () => audioHandler.skipToPrevious(),
                    icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                  ),
                  
                  // Play/Pause Button
                  StreamBuilder<PlaybackState>(
                    stream: audioHandler.playbackState,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return GlassContainer(
                        width: 80,
                        height: 80,
                        blur: 20,
                        opacity: 0.1,
                        borderRadius: BorderRadius.circular(40),
                        child: IconButton(
                          onPressed: () {
                            if (playing) {
                              audioHandler.pause();
                            } else {
                              audioHandler.play();
                            }
                          },
                          icon: Icon(
                            playing ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  IconButton(
                    onPressed: () => audioHandler.skipToNext(),
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                  ),
                  IconButton(
                    onPressed: () {}, // Loop
                    icon: const Icon(Icons.repeat, color: Colors.white54),
                  ),
                ],
              ),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}:${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes.remainder(60)}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
}
