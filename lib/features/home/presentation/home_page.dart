import 'package:aura/core/presentation/widgets/glass_container.dart';
import 'package:aura/core/services/permission_service.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/home/presentation/tabs/songs_tab.dart';
import 'package:aura/features/home/presentation/tabs/videos_tab.dart';
import 'package:aura/features/home/presentation/tabs/playlists_tab.dart';
import 'package:aura/features/home/presentation/tabs/folders_tab.dart';
import 'package:aura/features/home/presentation/tabs/artists_tab.dart';
import 'package:aura/features/home/presentation/tabs/albums_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _checkPermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final granted = await PermissionService.requestStoragePermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Storage permission is needed to load media.'),
            action: SnackBarAction(
                label: 'Settings',
                onPressed: () => PermissionService.openSettings()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.mainGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Aura Dashboard",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                    ),
                    GlassContainer(
                      height: 40,
                      width: 40,
                      blur: 10,
                      opacity: 0.2,
                      borderRadius: BorderRadius.circular(12),
                      child: IconButton(
                        icon: const Icon(Icons.shuffle, color: AppColors.neonCyan, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.neonCyan,
                  labelColor: AppColors.neonCyan,
                  unselectedLabelColor: Colors.white54,
                  dividerColor: Colors.transparent,
                  indicatorPadding: const EdgeInsets.only(top: 45),
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: "Songs"),
                    Tab(text: "Videos"),
                    Tab(text: "Playlists"),
                    Tab(text: "Folders"),
                    Tab(text: "Artists"),
                    Tab(text: "Albums"),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Tab Body
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    SongsTab(),
                    VideosTab(),
                    PlaylistsTab(),
                    FoldersTab(),
                    ArtistsTab(),
                    AlbumsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
