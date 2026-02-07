import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/providers/media_provider.dart';
import 'package:aura/core/presentation/widgets/glass_container.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlaylistsTab extends ConsumerWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(playlistsProvider);
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
              child: Text(
                'Playlists',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // Create New Playlist Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _CreatePlaylistCard(),
            ),
          ),

          // Content
          playlistsAsync.when(
            data: (playlists) {
              if (playlists.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(
                          Icons.queue_music_rounded,
                          color: AppColors.textSecondary,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No playlists yet',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first playlist above',
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
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final playlist = playlists[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PlaylistCard(
                          playlist: playlist,
                          onTap: () {
                            // TODO: Navigate to playlist detail page
                            print('Viewing playlist: ${playlist.playlist}');
                          },
                        ),
                      );
                    },
                    childCount: playlists.length,
                  ),
                ),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.neonCyan,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading playlists...',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.hotPink,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading playlists',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
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

class _CreatePlaylistCard extends StatefulWidget {
  @override
  State<_CreatePlaylistCard> createState() => _CreatePlaylistCardState();
}

class _CreatePlaylistCardState extends State<_CreatePlaylistCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        // TODO: Show create playlist dialog
        print('Create new playlist');
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.neonCyan.withOpacity(0.3),
                AppColors.electricPurple.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neonCyan.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.neonCyan,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Create New Playlist',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neonCyan,
                ),
              ),
            ],
          ),
        ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 2000.ms,
            color: AppColors.neonCyan.withOpacity(0.2),
          ),
      ),
    );
  }
}

class _PlaylistCard extends StatefulWidget {
  final dynamic playlist;
  final VoidCallback onTap;

  const _PlaylistCard({
    required this.playlist,
    required this.onTap,
  });

  @override
  State<_PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<_PlaylistCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: GlassContainer(
          height: 100,
          opacity: 0.08,
          blur: 15,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Stacked Album Art Effect
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  children: [
                    // Back layer
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.electricPurple.withOpacity(0.4),
                              AppColors.deepViolet.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Front layer
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.neonCyan.withOpacity(0.6),
                              AppColors.electricPurple.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonCyan.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.queue_music_rounded,
                          color: AppColors.neonCyan,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Playlist Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.playlist.playlist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.playlist.numOfSongs ?? 0} songs',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

