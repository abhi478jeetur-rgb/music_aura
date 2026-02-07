import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:aura/core/presentation/widgets/glass_container.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AlbumTile extends StatefulWidget {
  final AlbumModel album;
  final VoidCallback onTap;

  const AlbumTile({
    super.key,
    required this.album,
    required this.onTap,
  });

  @override
  State<AlbumTile> createState() => _AlbumTileState();
}

class _AlbumTileState extends State<AlbumTile> {
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
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: GlassContainer(
          opacity: 0.08,
          blur: 15,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Album Art with Hero Animation
              Expanded(
                child: Hero(
                  tag: 'album_${widget.album.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Album Artwork
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.electricPurple.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: QueryArtworkWidget(
                            id: widget.album.id,
                            type: ArtworkType.ALBUM,
                            artworkFit: BoxFit.cover,
                            artworkQuality: FilterQuality.high,
                            nullArtworkWidget: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.electricPurple.withOpacity(0.6),
                                    AppColors.deepViolet.withOpacity(0.8),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.album_rounded,
                                color: AppColors.neonCyan,
                                size: 64,
                              ),
                            ),
                          ),
                        ),
                        
                        // Year Badge (Bottom Left)
                        if (widget.album.numOfSongs != null)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: _buildBadge(
                              '${widget.album.numOfSongs} tracks',
                              Icons.music_note_rounded,
                            ),
                          ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(duration: 300.ms)
                    .scale(begin: const Offset(0.9, 0.9)),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Album Title
              Text(
                widget.album.album,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Artist Name
              Text(
                widget.album.artist ?? 'Unknown Artist',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.neonCyan.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.neonCyan,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
