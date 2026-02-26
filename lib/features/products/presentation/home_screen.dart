import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../providers/product_providers.dart';
import 'widgets/collapsible_header_delegate.dart';
import 'widgets/sticky_tab_bar_delegate.dart';
import 'widgets/product_page_view.dart';
import 'widgets/profile_drawer.dart';

/// HomeScreen – the architectural centrepiece.
///
/// SCROLL OWNERSHIP
/// ─────────────────
/// A single [CustomScrollView] owns ALL vertical scrolling.
/// It contains:
///   1. [SliverAppBar]                 → collapsible banner + search bar
///   2. [SliverPersistentHeader]       → sticky tab bar (pinned: true)
///   3. [SliverFillRemaining]          → [ProductPageView] (horizontal only)
///
/// The [ProductPageView] (PageView) has [NeverScrollableScrollPhysics] so it
/// cannot steal vertical scroll events. A [GestureDetector] in
/// [ProductPageView] intercepts intentional horizontal drags and drives the
/// [PageController] programmatically.
///
/// PULL-TO-REFRESH
/// ────────────────
/// A single [RefreshIndicator] wraps the [CustomScrollView].
/// It works regardless of which tab is active.
///
/// TAB SWITCHING
/// ──────────────
/// [activeTabIndexProvider] is the single source of truth for the active tab.
/// Both the [StickyTabBarDelegate] and [ProductPageView] read/write it.
/// Switching tabs does NOT reset scroll position because the vertical scroll
/// lives outside the PageView entirely.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// The ONE scroll controller for the entire screen.
  late final ScrollController _scrollController;

  /// Drives horizontal page transitions programmatically.
  late final PageController _pageController;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final categoriesAsync = ref.read(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? [];
    final activeIndex = ref.read(activeTabIndexProvider);
    final activeCategory = activeIndex < categories.length
        ? categories[activeIndex]
        : 'all';

    // Invalidate only the active tab's data to avoid unnecessary refetches
    ref.invalidate(productsProvider(activeCategory));

    // Wait for the refresh to complete
    await ref.read(productsProvider(activeCategory).future);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      key: _scaffoldKey,
      // Profile drawer on the right
      endDrawer: const ProfileDrawer(),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) => RefreshIndicator(
          // ── Single RefreshIndicator for the whole screen ──────────────
          color: AppTheme.primary,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            // ── THE ONE vertical scroll owner ─────────────────────────
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── 1. Collapsible header (banner + search) ────────────
              SliverPersistentHeader(
                pinned: false,
                floating: true,
                delegate: CollapsibleHeaderDelegate(
                  onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
              ),

              // ── 2. Sticky tab bar ──────────────────────────────────
              SliverPersistentHeader(
                pinned: true, // stays visible once header collapses
                delegate: StickyTabBarDelegate(
                  categories: categories,
                  pageController: _pageController,
                ),
              ),

              // ── 3. Product pages (horizontal only) ────────────────
              SliverFillRemaining(
                hasScrollBody: false,
                child: ProductPageView(
                  categories: categories,
                  pageController: _pageController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
