import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_providers.dart';
import 'product_list.dart';

/// [ProductPageView] hosts the horizontal [PageView].
///
/// HORIZONTAL SWIPE IMPLEMENTATION
/// ─────────────────────────────────
/// The [PageView] uses [NeverScrollableScrollPhysics] — it cannot scroll on
/// its own. Instead, a [GestureDetector] wraps the entire widget and detects
/// horizontal drag gestures. Only when the horizontal component of the drag
/// exceeds the vertical component (dx > dy) AND the velocity is intentional
/// (> 200 px/s) do we call [pageController.animateToPage].
///
/// This ensures:
///   • Vertical scrolling in [CustomScrollView] is NEVER hijacked.
///   • Horizontal swipes are intentional, not accidental.
///   • No gesture conflict between the two axes.
///
/// WHO OWNS VERTICAL SCROLL?
/// ──────────────────────────
/// The parent [CustomScrollView] (in HomeScreen) owns ALL vertical scroll.
/// [ProductPageView] deliberately has no vertical scroll physics.
/// Each tab's product list is rendered as a non-scrollable [Column] inside
/// [SliverFillRemaining], so the outer [CustomScrollView] handles all
/// vertical movement.
class ProductPageView extends ConsumerStatefulWidget {
  const ProductPageView({
    super.key,
    required this.categories,
    required this.pageController,
  });

  final List<String> categories;
  final PageController pageController;

  @override
  ConsumerState<ProductPageView> createState() => _ProductPageViewState();
}

class _ProductPageViewState extends ConsumerState<ProductPageView> {
  // Tracks drag start position for axis disambiguation
  Offset? _dragStart;

  void _onHorizontalSwipe(int delta) {
    final current = ref.read(activeTabIndexProvider);
    final next = (current + delta).clamp(0, widget.categories.length - 1);
    if (next == current) return;

    ref.read(activeTabIndexProvider.notifier).state = next;
    widget.pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // ── Horizontal swipe detection ────────────────────────────────────
      onHorizontalDragStart: (details) {
        _dragStart = details.globalPosition;
      },
      onHorizontalDragEnd: (details) {
        if (_dragStart == null) return;
        final velocity = details.primaryVelocity ?? 0;

        // Only act on intentional swipes (velocity threshold)
        if (velocity.abs() < 200) {
          _dragStart = null;
          return;
        }

        // velocity > 0 → swipe right → go to previous tab
        // velocity < 0 → swipe left  → go to next tab
        _onHorizontalSwipe(velocity > 0 ? -1 : 1);
        _dragStart = null;
      },
      // Prevent this GestureDetector from blocking vertical scrolling
      behavior: HitTestBehavior.translucent,
      child: PageView.builder(
        controller: widget.pageController,
        // ── CRITICAL: disable PageView's own scroll physics ───────────
        // The GestureDetector above handles horizontal navigation.
        // This prevents ANY conflict with the outer CustomScrollView.
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.categories.length,
        onPageChanged: (index) {
          // Sync tab bar when page changes (e.g. programmatic navigation)
          ref.read(activeTabIndexProvider.notifier).state = index;
        },
        itemBuilder: (context, index) {
          return ProductList(category: widget.categories[index]);
        },
      ),
    );
  }
}
