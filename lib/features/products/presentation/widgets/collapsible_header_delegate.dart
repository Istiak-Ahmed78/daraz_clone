import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Renders the collapsible banner + search bar.
///
/// Implements [SliverPersistentHeaderDelegate] so it integrates
/// natively with [CustomScrollView] — no magic numbers needed.
/// The header height interpolates between [minExtent] and [maxExtent]
/// as the user scrolls.
class CollapsibleHeaderDelegate extends SliverPersistentHeaderDelegate {
  const CollapsibleHeaderDelegate({required this.onMenuTap});

  final VoidCallback onMenuTap;

  static const double _maxHeight = 180.0;
  static const double _minHeight = 60.0;

  @override
  double get maxExtent => _maxHeight;

  @override
  double get minExtent => _minHeight;

  @override
  bool shouldRebuild(CollapsibleHeaderDelegate oldDelegate) => false;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // 0.0 = fully expanded, 1.0 = fully collapsed
    final collapse = (shrinkOffset / (_maxHeight - _minHeight)).clamp(0.0, 1.0);
    final showBanner = collapse < 0.5;

    return Container(
      color: AppTheme.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top bar (logo + icons) ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  // Logo
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
                    icon: const Icon(Icons.person_outline, color: Colors.white),
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

            // ── Search bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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

            // ── Promo banner (fades out as header collapses) ───────────
            if (showBanner)
              Expanded(
                child: AnimatedOpacity(
                  opacity: 1.0 - (collapse * 2).clamp(0.0, 1.0),
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
