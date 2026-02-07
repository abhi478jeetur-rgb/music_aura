import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/core/providers/folders_provider.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/presentation/widgets/glass_container.dart';

class FoldersTab extends ConsumerStatefulWidget {
  const FoldersTab({super.key});

  @override
  ConsumerState<FoldersTab> createState() => _FoldersTabState();
}

class _FoldersTabState extends ConsumerState<FoldersTab> {
  @override
  void initState() {
    super.initState();
    // Load folders when tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(foldersProvider.notifier).loadFolders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final foldersState = ref.watch(foldersProvider);

    // Loading state
    if (foldersState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.neonCyan,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading folders...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (foldersState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade300,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading folders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                foldersState.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(foldersProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
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
      );
    }

    // Empty state
    if (foldersState.folders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_off_outlined,
              color: Colors.white30,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'No folders found',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No media files available',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Folders list
    return RefreshIndicator(
      onRefresh: () => ref.read(foldersProvider.notifier).refresh(),
      color: AppColors.neonCyan,
      backgroundColor: AppColors.darkPurple,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: foldersState.folders.length,
        itemBuilder: (context, index) {
          final folder = foldersState.folders[index];
          return _FolderItem(
            folderName: folder.folderName,
            folderPath: folder.folderPath,
            songsCount: folder.songs.length,
            videosCount: folder.videos.length,
            totalItems: folder.totalItems,
            totalSize: folder.formattedTotalSize,
            totalDuration: folder.formattedTotalDuration,
            itemCountSummary: folder.itemCountSummary,
          );
        },
      ),
    );
  }
}

class _FolderItem extends StatefulWidget {
  final String folderName;
  final String folderPath;
  final int songsCount;
  final int videosCount;
  final int totalItems;
  final String totalSize;
  final String totalDuration;
  final String itemCountSummary;

  const _FolderItem({
    required this.folderName,
    required this.folderPath,
    required this.songsCount,
    required this.videosCount,
    required this.totalItems,
    required this.totalSize,
    required this.totalDuration,
    required this.itemCountSummary,
  });

  @override
  State<_FolderItem> createState() => _FolderItemState();
}

class _FolderItemState extends State<_FolderItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        blur: 10,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Folder header
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Folder icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.folder,
                        color: AppColors.neonCyan,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Folder info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.folderName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.itemCountSummary,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.storage,
                                size: 12,
                                color: Colors.white38,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.totalSize,
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: Colors.white38,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.totalDuration,
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Expand icon
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (_isExpanded)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Divider(
                      color: Colors.white12,
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    
                    // Songs count
                    if (widget.songsCount > 0)
                      _buildStatRow(
                        Icons.music_note,
                        'Songs',
                        widget.songsCount.toString(),
                        AppColors.neonCyan,
                      ),
                    
                    if (widget.songsCount > 0 && widget.videosCount > 0)
                      const SizedBox(height: 8),
                    
                    // Videos count
                    if (widget.videosCount > 0)
                      _buildStatRow(
                        Icons.videocam,
                        'Videos',
                        widget.videosCount.toString(),
                        AppColors.neonPurple,
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // View folder button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to folder details page
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening ${widget.folderName}...'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.folder_open, size: 18),
                        label: const Text('Open Folder'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonCyan.withOpacity(0.1),
                          foregroundColor: AppColors.neonCyan,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: AppColors.neonCyan.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
