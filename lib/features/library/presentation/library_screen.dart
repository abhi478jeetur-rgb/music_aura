import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/presentation/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Your Library',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      shadows: [
                        Shadow(
                          color: AppColors.neonCyan.withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Stat Cards (Horizontal Scroll)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildStatCard(
                        'Favorite Songs',
                        '247',
                        Icons.favorite_rounded,
                        AppColors.hotPink,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'Recently Added',
                        '32',
                        Icons.access_time_rounded,
                        AppColors.neonCyan,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'Total Playtime',
                        '48h',
                        Icons.play_circle_rounded,
                        AppColors.electricPurple,
                      ),
                    ],
                  ),
                ),
              ),

              // Section: Quick Access
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    'Quick Access',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick Access Items
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildQuickAccessItem(
                      'Liked Songs',
                      Icons.favorite_rounded,
                      AppColors.hotPink,
                      '247 songs',
                    ),
                    const SizedBox(height: 12),
                    _buildQuickAccessItem(
                      'Downloaded',
                      Icons.download_rounded,
                      AppColors.neonCyan,
                      '89 songs',
                    ),
                    const SizedBox(height: 12),
                    _buildQuickAccessItem(
                      'Recently Played',
                      Icons.history_rounded,
                      AppColors.electricPurple,
                      '156 songs',
                    ),
                    const SizedBox(height: 12),
                    _buildQuickAccessItem(
                      'Local Files',
                      Icons.folder_rounded,
                      const Color(0xFFFFD700),
                      '1,234 files',
                    ),
                  ]),
                ),
              ),

              // Section: Collections
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    'Collections',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Collections Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildCollectionCard(
                      'Playlists',
                      Icons.queue_music_rounded,
                      '24',
                      [AppColors.neonCyan, AppColors.electricPurple],
                    ),
                    _buildCollectionCard(
                      'Albums',
                      Icons.album_rounded,
                      '156',
                      [AppColors.electricPurple, AppColors.hotPink],
                    ),
                    _buildCollectionCard(
                      'Artists',
                      Icons.person_rounded,
                      '89',
                      [AppColors.hotPink, const Color(0xFFFF8E53)],
                    ),
                    _buildCollectionCard(
                      'Videos',
                      Icons.videocam_rounded,
                      '42',
                      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
                    ),
                  ]),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassContainer(
      width: 180,
      opacity: 0.1,
      blur: 15,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideX(begin: -0.2, end: 0);
  }

  Widget _buildQuickAccessItem(String title, IconData icon, Color color, String subtitle) {
    return GlassContainer(
      height: 80,
      opacity: 0.08,
      blur: 15,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideX(begin: -0.1, end: 0);
  }

  Widget _buildCollectionCard(String title, IconData icon, String count, List<Color> colors) {
    return GestureDetector(
      onTap: () {
        print('Navigate to $title');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors.map((c) => c.withOpacity(0.6)).toList(),
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors[0].withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

