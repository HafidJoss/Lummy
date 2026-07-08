class LoginRequest {
  final String email;
  final String password;
  LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  RegisterRequest({required this.email, required this.password, required this.fullName});
  Map<String, dynamic> toJson() => {'email': email, 'password': password, 'full_name': fullName};
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  
  AuthResponse({required this.accessToken, required this.refreshToken, required this.expiresIn});
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 86400,
    );
  }
}
