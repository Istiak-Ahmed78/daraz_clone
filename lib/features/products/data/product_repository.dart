import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/product_model.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.read(dioProvider));
});

// ── Repository ────────────────────────────────────────────────────────────────
class ProductRepository {
  const ProductRepository(this._dio);
  final Dio _dio;

  /// Fetches all available category names.
  Future<List<String>> fetchCategories() async {
    final response = await _dio.get('/products/categories');
    return List<String>.from(response.data as List);
  }

  /// Fetches all products (used for "All" tab).
  Future<List<Product>> fetchAllProducts() async {
    final response = await _dio.get('/products');
    return (response.data as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches products filtered by category.
  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response = await _dio.get('/products/category/$category');
    return (response.data as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
