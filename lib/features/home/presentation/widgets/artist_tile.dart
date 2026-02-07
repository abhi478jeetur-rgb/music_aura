import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:aura/core/presentation/widgets/glass_container.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ArtistTile extends StatefulWidget {
  final ArtistModel artist;
  final VoidCallback onTap;

  const ArtistTile({
    super.key,
    required this.artist,
    required this.onTap,
  });

  @override
  State<ArtistTile> createState() => _ArtistTileState();
}

class _ArtistTileState extends State<ArtistTile> {
  bool _isPressed = false;

  // Generate a unique color based on artist name
  Color _getArtistAuraColor() {
    final hash = widget.artist.artist.hashCode;
    final colors = [
      AppColors.neonCyan,
      AppColors.electricPurple,
      AppColors.hotPink,
      const Color(0xFF00FF88), // Neon Green
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF6B35), // Orange
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final auraColor = _getArtistAuraColor();

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
        child: Column(
          children: [
            // Circular Avatar with Aura Glow
            Hero(
              tag: 'artist_${widget.artist.id}',
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: auraColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: auraColor.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: QueryArtworkWidget(
                    id: widget.artist.id,
                    type: ArtworkType.ARTIST,
                    artworkWidth: 100,
                    artworkHeight: 100,
                    artworkFit: BoxFit.cover,
                    nullArtworkWidget: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            auraColor.withOpacity(0.6),
                            AppColors.deepViolet.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: auraColor,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  duration: 3000.ms,
                  color: auraColor.withOpacity(0.3),
                ),
            ),
            
            const SizedBox(height: 12),
            
            // Artist Name
            Text(
              widget.artist.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Track Count
            Text(
              '${widget.artist.numberOfTracks} ${widget.artist.numberOfTracks == 1 ? 'song' : 'songs'}',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
