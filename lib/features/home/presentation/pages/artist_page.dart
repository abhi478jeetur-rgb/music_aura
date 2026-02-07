import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/providers/media_provider.dart';
import 'package:aura/features/home/presentation/widgets/song_tile.dart';
import 'package:aura/features/player/presentation/player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:on_audio_query/on_audio_query.dart' as audio;

class ArtistPage extends ConsumerWidget {
  final audio.ArtistModel artist;

  const ArtistPage({super.key, required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsFromArtistProvider(artist.id));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header with Artist Info
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(context),
                title: Text(
                  artist.artist,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
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
                          'No songs found for this artist',
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

        // Artist artwork
        Padding(
          padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
          child: Column(
            children: [
              // Circular artist image with glow
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 75,
                  backgroundColor: AppColors.deepViolet,
                  child: Icon(
                    Icons.person_rounded,
                    size: 80,
                    color: AppColors.neonCyan,
                  ),
                ),
              ).animate().scale(duration: 400.ms).fadeIn(),

              const SizedBox(height: 16),

              // Artist name (appears in flexible space title when collapsed)
              Text(
                artist.artist,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 8),

              // Track count
              Text(
                '${artist.numberOfTracks ?? 0} ${artist.numberOfTracks == 1 ? 'track' : 'tracks'}',
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
