import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../domain/product_model.dart';

// ── Categories ────────────────────────────────────────────────────────────────
/// Fetches and caches the list of categories.
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  final cats = await repo.fetchCategories();
  return ['all', ...cats]; // "all" is always first tab
});

// ── Products per tab ──────────────────────────────────────────────────────────
/// Family provider: each category gets its own cached AsyncValue<List<Product>>.
final productsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  category,
) async {
  final repo = ref.read(productRepositoryProvider);
  if (category == 'all') {
    return repo.fetchAllProducts();
  }
  return repo.fetchProductsByCategory(category);
});

// ── Active tab index ──────────────────────────────────────────────────────────
/// Owned by HomeScreen. Drives both TabBar highlight and PageView page.
final activeTabIndexProvider = StateProvider<int>((_) => 0);
