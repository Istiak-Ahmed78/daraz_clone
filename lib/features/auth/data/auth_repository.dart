import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/auth_models.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.read(dioProvider),
    tokenRepo: ref.read(tokenProvider),
  );
});

// ── Repository ────────────────────────────────────────────────────────────────
class AuthRepository {
  const AuthRepository({required this.dio, required this.tokenRepo});

  final Dio dio;
  final TokenRepository tokenRepo;

  /// Authenticates user and persists the JWT token.
  /// FakeStore returns plain string "username or password is incorrect"
  /// on bad credentials — NOT a JSON body — so we handle both cases.
  Future<void> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: LoginRequest(username: username, password: password).toJson(),
      );

      // FakeStore sometimes returns 200 but with an error string body
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('token')) {
        final loginResponse = LoginResponse.fromJson(data);
        await tokenRepo.save(loginResponse.token);
      } else {
        // Body was not a valid token response
        throw const AuthException(
          'Invalid credentials. Please check your username and password.',
        );
      }
    } on DioException catch (e) {
      throw AuthException(_mapDioError(e));
    }
  }

  /// Fetches user profile by id.
  /// FakeStore users have IDs 1–10. We default to 1 for demo.
  Future<UserProfile> fetchProfile(int userId) async {
    try {
      final response = await dio.get('/users/$userId');
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_mapDioError(e));
    }
  }

  /// Checks if a token is stored (i.e., user is logged in).
  Future<bool> isLoggedIn() async {
    final token = await tokenRepo.read();
    return token != null;
  }

  /// Clears the stored token.
  Future<void> logout() => tokenRepo.delete();

  // ── Private Helpers ────────────────────────────────────────────────────────

  /// Maps DioException to a human-readable message.
  /// FakeStore can return 401, 400, or even 524 (timeout) $CITE_1
  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final body = e.response?.data;
        // FakeStore returns plain string on 401
        if (body is String && body.isNotEmpty) return body;
        if (statusCode == 401) return 'Invalid username or password.';
        if (statusCode == 400) return 'Bad request. Please try again.';
        return 'Server error ($statusCode). Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

// ── Typed Exception ────────────────────────────────────────────────────────────
/// A clean typed exception for auth errors.
/// Avoids leaking raw Dio internals to the UI layer. $CITE_6
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
