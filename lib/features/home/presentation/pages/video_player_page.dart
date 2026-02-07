import 'dart:async';
import 'dart:io';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/models/video_model.dart';
import 'package:aura/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoPlayerPage extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  late Box _positionsBox;
  Timer? _savePositionTimer;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
    _positionsBox = Hive.box(StorageService.settingsBox);
  }

  Future<void> _initVideoPlayer() async {
    try {
      // Pause any background audio
      await _pauseBackgroundAudio();

      // Initialize video player from file path
      _videoPlayerController = VideoPlayerController.file(
        File(widget.video.filePath),
      );

      await _videoPlayerController.initialize();

      // Get saved position
      final savedPosition = _getSavedPosition();

      // Create chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        startAt: savedPosition,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.hotPink,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error playing video',
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.neonCyan,
          handleColor: AppColors.neonCyan,
          backgroundColor: AppColors.textSecondary.withOpacity(0.3),
          bufferedColor: AppColors.textSecondary.withOpacity(0.5),
        ),
      );

      // Start periodic position saving
      _startPositionSaving();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// Pause background audio (just_audio)
  Future<void> _pauseBackgroundAudio() async {
    // Note: This will be implemented when we integrate with the audio handler provider
    // For now, playing video will naturally pause audio through system audio focus
  }

  /// Get saved playback position
  Duration _getSavedPosition() {
    final key = 'video_position_${widget.video.id}';
    final savedMs = _positionsBox.get(key, defaultValue: 0) as int;
    return Duration(milliseconds: savedMs);
  }

  /// Save current position
  void _savePosition() {
    if (_videoPlayerController.value.isInitialized) {
      final key = 'video_position_${widget.video.id}';
      final currentMs = _videoPlayerController.value.position.inMilliseconds;
      _positionsBox.put(key, currentMs);
    }
  }

  /// Start timer to periodically save position
  void _startPositionSaving() {
    _savePositionTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _savePosition(),
    );
  }

  @override
  void dispose() {
    _savePositionTimer?.cancel();
    _savePosition(); // Save one last time
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Player
            if (_isInitialized && _chewieController != null)
              Center(
                child: Chewie(controller: _chewieController!),
              )
            else if (_hasError)
              _buildErrorView()
            else
              _buildLoadingView(),

            // Back Button
            Positioned(
              top: 16,
              left: 16,
              child: Material(
                color: Colors.black.withOpacity(0.5),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Video Info (Bottom)
            if (_isInitialized)
              Positioned(
                bottom: 80,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.video.title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.hd_rounded,
                            color: AppColors.neonCyan,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.video.qualityLabel,
                            style: GoogleFonts.inter(
                              color: AppColors.neonCyan,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.folder_rounded,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.video.formattedSize,
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 12,
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
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.neonCyan,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading video...',
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.hotPink,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load video',
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unknown error',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
