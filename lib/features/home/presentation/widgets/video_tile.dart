import 'dart:io';
import 'package:aura/core/presentation/widgets/glass_container.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:aura/core/models/video_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VideoTile extends StatefulWidget {
  final VideoModel video;
  final VoidCallback onTap;

  const VideoTile({
    super.key,
    required this.video,
    required this.onTap,
  });

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
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
              // Video Thumbnail with Hero Animation
              Expanded(
                child: Hero(
                  tag: 'video_${widget.video.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Thumbnail
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.electricPurple.withOpacity(0.3),
                                AppColors.deepViolet.withOpacity(0.5),
                              ],
                            ),
                          ),
                          child: widget.video.thumbnail != null
                              ? Image.file(
                                  File(widget.video.thumbnail!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                        ),
                        
                        // Play Icon Overlay
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.neonCyan,
                              size: 32,
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                            .shimmer(
                              duration: 2000.ms,
                              color: AppColors.neonCyan.withOpacity(0.3),
                            ),
                        ),
                        
                        // Duration Badge (Top Right)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _buildBadge(
                            widget.video.formattedDuration,
                            Icons.schedule,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Video Title
              Text(
                widget.video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
              ),
              
              const SizedBox(height: 8),
              
              // Resolution Badge
              Row(
                children: [
                  _buildBadge(
                    widget.video.qualityLabel,
                    Icons.hd_rounded,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.video.formattedSize,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.deepViolet.withOpacity(0.5),
      child: Center(
        child: Icon(
          Icons.videocam_rounded,
          color: AppColors.neonCyan.withOpacity(0.5),
          size: 48,
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
            style: TextStyle(
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
