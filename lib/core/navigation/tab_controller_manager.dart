import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tab State Model for Home Dashboard
class TabState {
  final int currentTabIndex;
  final List<String> tabLabels;

  TabState({
    required this.currentTabIndex,
    required this.tabLabels,
  });

  TabState copyWith({int? currentTabIndex}) {
    return TabState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      tabLabels: tabLabels,
    );
  }
}

/// Tab Controller Manager - Manages 6 tabs in Home Dashboard
class TabControllerManager extends Notifier<TabState> {
  @override
  TabState build() {
    return TabState(
      currentTabIndex: 0,
      tabLabels: const [
        'Songs',
        'Videos',
        'Playlists',
        'Folders',
        'Artists',
        'Albums',
      ],
    );
  }

  /// Change to a specific tab
  void changeTab(int index) {
    if (index >= 0 && index < state.tabLabels.length) {
      state = state.copyWith(currentTabIndex: index);
    }
  }

  /// Get current tab label
  String get currentTabLabel => state.tabLabels[state.currentTabIndex];

  /// Get total number of tabs
  int get tabCount => state.tabLabels.length;
}

/// Provider for Tab Controller Manager
final tabControllerManagerProvider =
    NotifierProvider<TabControllerManager, TabState>(() {
  return TabControllerManager();
});
