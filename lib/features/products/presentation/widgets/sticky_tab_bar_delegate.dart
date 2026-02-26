import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/product_providers.dart';

/// Sticky tab bar that pins to the top once the collapsible header scrolls away.
///
/// Uses [SliverPersistentHeaderDelegate] with [pinned: true] in the parent
/// [CustomScrollView]. This means the tab bar is ALWAYS visible once the
/// header collapses — no magic offsets needed.
///
/// Tab taps update [activeTabIndexProvider] and animate the [PageController].
/// The PageView listens to the same provider and syncs accordingly.
class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const StickyTabBarDelegate({
    required this.categories,
    required this.pageController,
  });

  final List<String> categories;
  final PageController pageController;

  static const double _height = 48.0;

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(StickyTabBarDelegate oldDelegate) =>
      oldDelegate.categories != categories;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _TabBarWidget(
      categories: categories,
      pageController: pageController,
    );
  }
}

/// Separated into a [ConsumerWidget] so it can watch Riverpod providers.
/// [SliverPersistentHeaderDelegate.build] is not a widget build context
/// that supports hooks/providers directly.
class _TabBarWidget extends ConsumerWidget {
  const _TabBarWidget({required this.categories, required this.pageController});

  final List<String> categories;
  final PageController pageController;

  String _label(String cat) => cat[0].toUpperCase() + cat.substring(1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(activeTabIndexProvider);

    return Container(
      color: AppTheme.surface,
      height: 48,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isActive = index == activeIndex;
                return GestureDetector(
                  onTap: () {
                    ref.read(activeTabIndexProvider.notifier).state = index;
                    pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? AppTheme.primary : AppTheme.divider,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _label(categories[index]),
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppTheme.divider),
        ],
      ),
    );
  }
}
