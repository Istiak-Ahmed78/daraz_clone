import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/product_providers.dart';
import 'product_card.dart';

/// Renders the product grid for a single tab/category.
///
/// IMPORTANT: This widget must NOT introduce its own scroll.
/// It renders as a plain [Column] + [Wrap] so the parent
/// [CustomScrollView] handles all vertical scrolling.
///
/// [AutomaticKeepAliveClientMixin] is intentionally NOT used here
/// because scroll position is owned by the outer [CustomScrollView],
/// not by individual pages. Riverpod's [FutureProvider.family] caches
/// the data, so re-entering a tab does not re-fetch.
class ProductList extends ConsumerWidget {
  const ProductList({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider(category));

    return productsAsync.when(
      loading: () => _ShimmerGrid(),
      error: (e, _) => _ErrorWidget(message: e.toString()),
      data: (products) {
        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'No products found.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          );
        }

        // ── Grid layout using Wrap (no scroll) ────────────────────────
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: products
                .map(
                  (p) => SizedBox(
                    width: (MediaQuery.of(context).size.width - 24) / 2,
                    child: ProductCard(product: p),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

// ── Shimmer loading skeleton ──────────────────────────────────────────────────
class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          6,
          (i) => SizedBox(
            width: (MediaQuery.of(context).size.width - 24) / 2,
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error widget ──────────────────────────────────────────────────────────────
class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
