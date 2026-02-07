import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/providers/media_provider.dart';
import 'package:aura/features/home/presentation/widgets/artist_tile.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ArtistsTab extends ConsumerWidget {
  const ArtistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistsAsync = ref.watch(artistsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(artistsProvider);
      },
      backgroundColor: AppColors.deepViolet,
      color: AppColors.neonCyan,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Artists',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      artistsAsync.when(
                        data: (artists) => Text(
                          '${artists.length} artists',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        loading: () => Text(
                          'Loading...',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        error: (_, __) => Text(
                          'Error',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.hotPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Sort Button
                  IconButton(
                    onPressed: () {
                      // TODO: Implement sorting
                    },
                    icon: const Icon(
                      Icons.sort_by_alpha_rounded,
                      color: AppColors.neonCyan,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          artistsAsync.when(
            data: (artists) {
              if (artists.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          color: AppColors.textSecondary,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No artists found',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pull down to refresh',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 24,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final artist = artists[index];
                      return ArtistTile(
                        artist: artist,
                        onTap: () {
                          // TODO: Navigate to artist detail page
                          print('Viewing artist: ${artist.artist}');
                        },
                      );
                    },
                    childCount: artists.length,
                  ),
                ),
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.neonCyan,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading artists...',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.hotPink,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading artists',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
    );
  }
}

