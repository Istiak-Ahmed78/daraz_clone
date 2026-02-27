class LoginRequest {
  const LoginRequest({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

// ─────────────────────────────────────────────────────────────

class LoginResponse {
  const LoginResponse({required this.token});

  final String token;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      LoginResponse(token: json['token'] as String);
}

// ─────────────────────────────────────────────────────────────

class AuthFailure {
  const AuthFailure({required this.message});

  final String message;

  @override
  String toString() => message;
}
