import '../../domain/entities/auth_tokens.dart';

class LoginResponse {
  const LoginResponse({
    required this.access,
    required this.refresh,
  });

  final String access;
  final String refresh;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }

  AuthTokens toEntity() {
    return AuthTokens(access: access, refresh: refresh);
  }
}
