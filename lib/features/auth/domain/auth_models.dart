import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

// ── Login Request ─────────────────────────────────────────────────────────────
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String username,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

// ── Login Response ────────────────────────────────────────────────────────────
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({required String token}) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

// ── User Profile ──────────────────────────────────────────────────────────────
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int id,
    required String email,
    required String username,
    required String phone,
    required UserName name,
    required UserAddress address,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class UserName with _$UserName {
  const factory UserName({
    required String firstname,
    required String lastname,
  }) = _UserName;

  factory UserName.fromJson(Map<String, dynamic> json) =>
      _$UserNameFromJson(json);
}

@freezed
class UserAddress with _$UserAddress {
  const factory UserAddress({
    required String city,
    required String street,
    required String zipcode,
  }) = _UserAddress;

  factory UserAddress.fromJson(Map<String, dynamic> json) =>
      _$UserAddressFromJson(json);
}
