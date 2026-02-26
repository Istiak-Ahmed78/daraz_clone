import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

const String _baseUrl = 'https://fakestoreapi.com';
const String _tokenKey = 'auth_token';

final _logger = Logger();

// ── Secure storage provider ──────────────────────────────────────────────────
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

// ── Dio provider ─────────────────────────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Request interceptor – attach token if available
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        _logger.d('[REQ] ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.d('[RES] ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('[ERR] ${error.message}');
        handler.next(error);
      },
    ),
  );

  return dio;
});

// ── Token helpers ─────────────────────────────────────────────────────────────
final tokenProvider = Provider<TokenRepository>((ref) {
  return TokenRepository(ref.read(secureStorageProvider));
});

class TokenRepository {
  const TokenRepository(this._storage);
  final FlutterSecureStorage _storage;

  Future<void> save(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> read() => _storage.read(key: _tokenKey);
  Future<void> delete() => _storage.delete(key: _tokenKey);
}