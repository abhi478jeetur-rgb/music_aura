import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/providers/media_provider.dart';
import 'package:aura/features/home/presentation/widgets/video_tile.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class VideosTab extends ConsumerStatefulWidget {
  const VideosTab({super.key});

  @override
  ConsumerState<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends ConsumerState<VideosTab> {
  @override
  void initState() {
    super.initState();
    // Load videos when tab is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videosProvider.notifier).loadVideos();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(videosProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final videosState = ref.watch(videosProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
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
                        'Videos',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${videosState.videos.length} videos',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
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
          if (videosState.isLoading && videosState.videos.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.neonCyan,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading videos...',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (videosState.error != null)
            SliverFillRemaining(
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
                      'Error loading videos',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      videosState.error!,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _onRefresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonCyan,
                        foregroundColor: AppColors.deepViolet,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (videosState.videos.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_off_rounded,
                      color: AppColors.textSecondary,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No videos found',
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
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final video = videosState.videos[index];
                    return VideoTile(
                      video: video,
                      onTap: () {
                        // TODO: Navigate to video player
                        print('Playing video: ${video.title}');
                      },
                    );
                  },
                  childCount: videosState.videos.length,
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
