import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CollapsibleHeaderDelegate extends SliverPersistentHeaderDelegate {
  const CollapsibleHeaderDelegate({
    required this.onMenuTap,
    required this.topPadding,
  });

  final VoidCallback onMenuTap;
  final double topPadding;

  static const double _topBarHeight = 56.0;
  static const double _searchHeight = 56.0;
  static const double _bannerHeight = 68.0;

  @override
  double get maxExtent =>
      topPadding + _topBarHeight + _searchHeight + _bannerHeight;

  @override
  double get minExtent => topPadding + _topBarHeight;

  @override
  bool shouldRebuild(CollapsibleHeaderDelegate oldDelegate) =>
      oldDelegate.topPadding != topPadding;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // How much of the collapsible range has been consumed
    final collapsibleRange =
        maxExtent - minExtent; // = searchHeight + bannerHeight
    final collapse = collapsibleRange == 0
        ? 0.0
        : (shrinkOffset / collapsibleRange).clamp(0.0, 1.0);

    // Banner fades out in the first half of the collapse
    final bannerOpacity = (1.0 - collapse * 2).clamp(0.0, 1.0);

    // Remaining height after shrinkOffset is applied
    final availableHeight =
        (maxExtent - shrinkOffset).clamp(minExtent, maxExtent);

    final computedBannerHeight =
        (availableHeight - topPadding - _topBarHeight - _searchHeight)
            .clamp(0.0, _bannerHeight);

    return ClipRect(
      // clips sub-pixel overflow during animation
      child: Container(
        color: AppTheme.primary,
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top bar (logo + icons) ─────────────────────────────
            SizedBox(
              height: _topBarHeight,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      'daraz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      onPressed: onMenuTap,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // ── Search bar ─────────────────────────────────────────
            if (computedBannerHeight > 0 || collapse < 1.0)
              SizedBox(
                height: _searchHeight.clamp(
                  0.0,
                  (availableHeight - topPadding - _topBarHeight)
                      .clamp(0.0, _searchHeight),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── Promo banner ───────────────────────────────────────
            if (computedBannerHeight > 0)
              SizedBox(
                height: computedBannerHeight,
                child: AnimatedOpacity(
                  opacity: bannerOpacity,
                  duration: Duration.zero,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.8),
                          AppTheme.secondary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '🔥  Mega Sale — Up to 70% Off!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
