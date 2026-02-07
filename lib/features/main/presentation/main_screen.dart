import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/home/presentation/home_page.dart';
import 'package:aura/features/library/presentation/library_screen.dart';
import 'package:aura/features/search/presentation/search_screen.dart';
import 'package:aura/features/settings/presentation/settings_screen.dart';
import 'package:aura/core/presentation/widgets/glass_container.dart';
import 'package:aura/core/navigation/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final List<Widget> _screens = const [
    HomePage(),
    SearchScreen(),
    LibraryScreen(),
    SettingsScreen(),
  ];

  @override
  void dispose() {
    // PageController will be disposed by NavigationController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigationState = ref.watch(navigationControllerProvider);
    final navigationController = ref.read(navigationControllerProvider.notifier);

    return Scaffold(
      body: PageView(
        controller: navigationState.pageController,
        onPageChanged: navigationController.onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: GlassContainer(
          height: 70,
          blur: 30, // Increased blur for more frosted effect
          opacity: 0.08, // Slightly more opaque for better frosting
          borderRadius: BorderRadius.circular(30),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, "Home", navigationState.currentIndex, navigationController),
                _buildNavItem(1, Icons.search_rounded, "Search", navigationState.currentIndex, navigationController),
                _buildNavItem(2, Icons.library_music_rounded, "Library", navigationState.currentIndex, navigationController),
                _buildNavItem(3, Icons.settings_rounded, "Settings", navigationState.currentIndex, navigationController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    int currentIndex,
    NavigationController controller,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => controller.navigateToIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonCyan.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.neonCyan.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.neonCyan : Colors.white54,
          size: 28,
          shadows: isSelected
              ? [
                  Shadow(
                    color: AppColors.neonCyan.withOpacity(0.8),
                    blurRadius: 10,
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}
