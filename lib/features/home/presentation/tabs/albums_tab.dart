import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/providers/media_provider.dart';
import 'package:aura/features/home/presentation/widgets/album_tile.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AlbumsTab extends ConsumerWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(albumsProvider);
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
                        'Albums',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      albumsAsync.when(
                        data: (albums) => Text(
                          '${albums.length} albums',
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
                      Icons.sort_rounded,
                      color: AppColors.neonCyan,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          albumsAsync.when(
            data: (albums) {
              if (albums.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.album_outlined,
                          color: AppColors.textSecondary,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No albums found',
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
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final album = albums[index];
                      return AlbumTile(
                        album: album,
                        onTap: () {
                          // TODO: Navigate to album detail page
                          print('Viewing album: ${album.album}');
                        },
                      );
                    },
                    childCount: albums.length,
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
                      'Loading albums...',
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
                      'Error loading albums',
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

