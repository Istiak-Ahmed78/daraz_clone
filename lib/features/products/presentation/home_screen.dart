import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/product_providers.dart';
import 'widgets/collapsible_header_delegate.dart';
import 'widgets/sticky_tab_bar_delegate.dart';
import 'widgets/product_page_view.dart';
import 'widgets/profile_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ScrollController _scrollController;
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
    final activeCategory =
        activeIndex < categories.length ? categories[activeIndex] : 'all';
    ref.invalidate(productsProvider(activeCategory));
    await ref.read(productsProvider(activeCategory).future);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const ProfileDrawer(),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) => RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── 1. Collapsible header ────────────────────────────
              SliverPersistentHeader(
                pinned: false,
                floating: true,
                delegate: CollapsibleHeaderDelegate(
                  onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                  topPadding: topPadding,
                ),
              ),

              // ── 2. Sticky tab bar ────────────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyTabBarDelegate(
                  categories: categories,
                  pageController: _pageController,
                ),
              ),

              // ── 3. Product pages ─────────────────────────────────
              SliverFillRemaining(
                hasScrollBody: true,
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
