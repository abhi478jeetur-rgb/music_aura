import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int currentIndex;
  final PageController pageController;

  NavigationState({
    required this.currentIndex,
    required this.pageController,
  });

  NavigationState copyWith({
    int? currentIndex,
    PageController? pageController,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      pageController: pageController ?? this.pageController,
    );
  }
}

class NavigationController extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    return NavigationState(
      currentIndex: 0,
      pageController: PageController(initialPage: 0),
    );
  }

  void navigateToIndex(int index) {
    state.pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    state = state.copyWith(currentIndex: index);
  }

  void onPageChanged(int index) {
    state = state.copyWith(currentIndex: index);
  }

  // Notifier doesn't have dispose() in the same way, but we can handle it in build or a specific method.
  // However, usually we use ref.onDispose in the build method.
  void setupDisposal() {
    ref.onDispose(() {
      state.pageController.dispose();
    });
  }
}

final navigationControllerProvider =
    NotifierProvider<NavigationController, NavigationState>(() {
  return NavigationController();
});
