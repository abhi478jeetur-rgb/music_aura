import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/presentation/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'Cyber Purple';
  bool _notificationsEnabled = true;
  bool _downloadOnWifi = true;
  bool _highQuality = false;

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
                    'Settings',
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

              // Theme Preview Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Preview',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildThemeCard(
                              'Cyber Purple',
                              AppColors.electricPurple,
                              AppColors.neonCyan,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildThemeCard(
                              'Deep Blue',
                              const Color(0xFF1E3A8A),
                              const Color(0xFF60A5FA),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Playback Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    'Playback',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSettingTile(
                      'Audio Quality',
                      'High quality streaming',
                      Icons.high_quality_rounded,
                      AppColors.neonCyan,
                      trailing: Switch(
                        value: _highQuality,
                        onChanged: (value) {
                          setState(() => _highQuality = value);
                        },
                        activeColor: AppColors.neonCyan,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingTile(
                      'Download on WiFi Only',
                      'Save mobile data',
                      Icons.wifi_rounded,
                      AppColors.electricPurple,
                      trailing: Switch(
                        value: _downloadOnWifi,
                        onChanged: (value) {
                          setState(() => _downloadOnWifi = value);
                        },
                        activeColor: AppColors.neonCyan,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingTile(
                      'Equalizer',
                      'Customize your sound',
                      Icons.equalizer_rounded,
                      AppColors.hotPink,
                    ),
                  ]),
                ),
              ),

              // Notifications Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    'Notifications',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSettingTile(
                      'Push Notifications',
                      'Get updates about new releases',
                      Icons.notifications_rounded,
                      const Color(0xFFFFD700),
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                        },
                        activeColor: AppColors.neonCyan,
                      ),
                    ),
                  ]),
                ),
              ),

              // Storage Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    'Storage',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSettingTile(
                      'Clear Cache',
                      '245 MB cached data',
                      Icons.cleaning_services_rounded,
                      const Color(0xFFFF8E53),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingTile(
                      'Storage Location',
                      'Internal storage',
                      Icons.sd_storage_rounded,
                      const Color(0xFF4FACFE),
                    ),
                  ]),
                ),
              ),

              // About Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                  child: Text(
                    'About',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSettingTile(
                      'Version',
                      '1.0.0',
                      Icons.info_rounded,
                      AppColors.neonCyan,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingTile(
                      'Privacy Policy',
                      'View our privacy policy',
                      Icons.privacy_tip_rounded,
                      AppColors.electricPurple,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingTile(
                      'Terms of Service',
                      'View terms and conditions',
                      Icons.description_rounded,
                      AppColors.hotPink,
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

  Widget _buildThemeCard(String name, Color primary, Color accent) {
    final isSelected = _selectedTheme == name;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTheme = name);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withOpacity(0.6),
              accent.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accent : accent.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.palette_rounded,
                      color: accent,
                      size: 20,
                    ),
                  ),
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ).animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor, {
    Widget? trailing,
  }) {
    return GlassContainer(
      opacity: 0.08,
      blur: 15,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          if (trailing != null)
            trailing
          else
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
}

