import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/providers/media_provider.dart';
import 'package:aura/features/home/presentation/widgets/song_tile.dart';
import 'package:aura/features/player/presentation/player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio;

class AlbumPage extends ConsumerWidget {
  final audio.AlbumModel album;

  const AlbumPage({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsFromAlbumProvider(album.id));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header with Album Info
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(context),
                title: Text(
                  album.album,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Songs List
            songsAsync.when(
              data: (songs) {
                if (songs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No songs found in this album',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = songs[index];
                      return SongTile(
                        song: song,
                        onTap: () {
                          // Navigate to player
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerPage(song: song),
                            ),
                          );
                        },
                      )
                          .animate(delay: (index * 50).ms)
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: -0.2, end: 0);
                    },
                    childCount: songs.length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: CircularProgressIndicator(
                      color: AppColors.neonCyan,
                    ),
                  ),
                ),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'Error loading songs: $error',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.neonPurple.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Album artwork and details
        Padding(
          padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
          child: Column(
            children: [
              // Album artwork with glow effect
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: audio.QueryArtworkWidget(
                    id: album.id,
                    type: audio.ArtworkType.ALBUM,
                    artworkFit: BoxFit.cover,
                    artworkBorder: BorderRadius.zero,
                    nullArtworkWidget: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.neonPurple,
                            AppColors.neonCyan,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.album_rounded,
                        size: 90,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ).animate().scale(duration: 400.ms).fadeIn(),

              const SizedBox(height: 20),

              // Album name
              Text(
                album.album,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 8),

              // Artist name
              if (album.artist != null && album.artist!.isNotEmpty)
                Text(
                  album.artist!,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 150.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 8),

              // Track count
              Text(
                '${album.numOfSongs ?? 0} ${album.numOfSongs == 1 ? 'track' : 'tracks'}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.neonCyan,
                  fontWeight: FontWeight.w500,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ],
    );
  }
}
