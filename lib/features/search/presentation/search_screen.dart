import 'dart:async';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/presentation/widgets/glass_container.dart';
import 'package:aura/features/search/presentation/providers/search_provider.dart';
import 'package:aura/features/home/presentation/widgets/song_tile.dart';
import 'package:aura/features/home/presentation/widgets/artist_tile.dart';
import 'package:aura/features/home/presentation/widgets/album_tile.dart';
import 'package:aura/features/home/presentation/widgets/video_tile.dart';
import 'package:aura/features/home/presentation/pages/artist_page.dart';
import 'package:aura/features/home/presentation/pages/album_page.dart';
import 'package:aura/features/home/presentation/pages/video_player_page.dart';
import 'package:aura/features/player/presentation/player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final List<String> _recentSearches = ['Summer Vibes', 'Workout Mix', 'Chill Beats'];
  
  // Debounce timer for search
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Create new timer - search after 300ms of no typing
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text;
      ref.read(searchProvider.notifier).search(query);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final isSearching = _searchController.text.isNotEmpty;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header with Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Floating Search Bar with Glow
                      _buildSearchBar(),
                    ],
                  ),
                ),
              ),

              // Search Results or Browse UI
              if (isSearching)
                ..._buildSearchResults(searchState)
              else
                ..._buildBrowseUI(),

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

  /// Build search results sections
  List<Widget> _buildSearchResults(SearchResultState state) {
    if (state.isSearching) {
      return [
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: CircularProgressIndicator(
                color: AppColors.neonCyan,
              ),
            ),
          ),
        ),
      ];
    }

    if (!state.hasResults) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No results found',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final results = <Widget>[];

    // Songs Section
    if (state.songs.isNotEmpty) {
      results.add(_buildResultSection('Songs', state.songs.length));
      results.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final song = state.songs[index];
              return SongTile(
                song: song,
                onTap: () {
                  // Navigate to player
                  // TODO: Update PlayerPage to accept songs list and initialIndex for queue support
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerPage(song: song),
                    ),
                  );
                },
              );
            },
            childCount: state.songs.length > 5 ? 5 : state.songs.length,
          ),
        ),
      );
    }

    // Artists Section
    if (state.artists.isNotEmpty) {
      results.add(_buildResultSection('Artists', state.artists.length));
      results.add(
        SliverToBoxAdapter(
          child: SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.artists.length,
              itemBuilder: (context, index) {
                final artist = state.artists[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ArtistTile(
                    artist: artist,
                    onTap: () {
                      // Navigate to artist detail page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArtistPage(artist: artist),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    // Albums Section
    if (state.albums.isNotEmpty) {
      results.add(_buildResultSection('Albums', state.albums.length));
      results.add(
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.albums.length,
              itemBuilder: (context, index) {
                final album = state.albums[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AlbumTile(
                    album: album,
                    onTap: () {
                      // Navigate to album detail page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlbumPage(album: album),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    // Videos Section
    if (state.videos.isNotEmpty) {
      results.add(_buildResultSection('Videos', state.videos.length));
      results.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final video = state.videos[index];
              return VideoTile(
                video: video,
                onTap: () {
                  // Navigate to video player
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerPage(video: video),
                    ),
                  );
                },
              );
            },
            childCount: state.videos.length > 3 ? 3 : state.videos.length,
          ),
        ),
      );
    }

    return results;
  }

  /// Build browse UI (categories)
  List<Widget> _buildBrowseUI() {
    return [
      // Recent Searches
      if (_recentSearches.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Recent Searches',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentSearches
                      .map((search) => _buildRecentSearchChip(search))
                      .toList(),
                ),
              ],
            ),
          ),
        ),

      // Category Tiles
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Browse by Mood',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // Category Grid
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildListDelegate([
            _buildCategoryTile(
              'Chill',
              Icons.spa_rounded,
              [const Color(0xFF667EEA), const Color(0xFF764BA2)],
            ),
            _buildCategoryTile(
              'Workout',
              Icons.fitness_center_rounded,
              [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
            ),
            _buildCategoryTile(
              'Focus',
              Icons.psychology_rounded,
              [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
            ),
            _buildCategoryTile(
              'Party',
              Icons.celebration_rounded,
              [const Color(0xFFFA709A), const Color(0xFFFEE140)],
            ),
            _buildCategoryTile(
              'Sleep',
              Icons.nightlight_round,
              [const Color(0xFF2E3192), const Color(0xFF1BFFFF)],
            ),
            _buildCategoryTile(
              'Retro',
              Icons.album_rounded,
              [const Color(0xFFFFD89B), const Color(0xFF19547B)],
            ),
          ]),
        ),
      ),
    ];
  }

  /// Build result section header
  Widget _buildResultSection(String title, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonCyan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassContainer(
      opacity: 0.1,
      blur: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'Search songs, artists, albums...',
            hintStyle: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.neonCyan,
              size: 24,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onChanged: (value) {
            setState(() {});
            // TODO: Implement search logic
          },
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: -0.2, end: 0);
  }

  Widget _buildRecentSearchChip(String search) {
    return GestureDetector(
      onTap: () {
        _searchController.text = search;
        // TODO: Perform search
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.deepViolet.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonCyan.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              color: AppColors.neonCyan,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              search,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: 100.ms)
      .slideX(begin: -0.2, end: 0);
  }

  Widget _buildCategoryTile(String title, IconData icon, List<Color> colors) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to category
        print('Category: $title');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Icon (Large, Faded)
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8)),
    );
  }
}

