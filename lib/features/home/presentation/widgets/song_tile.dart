import 'package:aura/core/models/song_model.dart';
import 'package:aura/core/presentation/widgets/glass_container.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:google_fonts/google_fonts.dart';

class SongTile extends StatefulWidget {
  final AuraSongModel song;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
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
            height: 80,
            width: double.infinity,
            opacity: 0.06,
            blur: 12,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Album Art with Hero Animation
                Hero(
                  tag: 'artwork_${widget.song.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCyan.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: QueryArtworkWidget(
                        id: widget.song.id,
                        type: ArtworkType.AUDIO,
                        artworkWidth: 56,
                        artworkHeight: 56,
                        artworkFit: BoxFit.cover,
                        artworkBorder: BorderRadius.circular(12),
                        nullArtworkWidget: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.electricPurple.withOpacity(0.6),
                                AppColors.deepViolet.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.music_note_rounded,
                            color: AppColors.neonCyan,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Song Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.song.artist ?? "Unknown Artist",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Duration and Menu
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDuration(widget.song.duration ?? 0),
                      style: GoogleFonts.inter(
                        color: AppColors.neonCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        // TODO: Show song options menu
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

