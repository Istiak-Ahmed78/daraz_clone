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
  Future<void> login(String username, String password) async {
    final response = await dio.post(
      '/auth/login',
      data: LoginRequest(username: username, password: password).toJson(),
    );
    final loginResponse = LoginResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
    await tokenRepo.save(loginResponse.token);
  }

  /// Fetches user profile by id.
  /// FakeStore users have IDs 1–10. We default to 1 for demo.
  Future<UserProfile> fetchProfile(int userId) async {
    final response = await dio.get('/users/$userId');
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  /// Checks if a token is stored (i.e., user is logged in).
  Future<bool> isLoggedIn() async {
    final token = await tokenRepo.read();
    return token != null;
  }

  /// Clears the stored token.
  Future<void> logout() => tokenRepo.delete();
}
