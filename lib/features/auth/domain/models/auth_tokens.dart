class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String? username;

  AuthTokens({required this.accessToken, required this.refreshToken, this.username});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
        username: json['username'],
      );
}
