class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String typeOfUser;
  final String? username;

  AuthTokens({required this.accessToken, required this.refreshToken, required this.userId, required this.typeOfUser, this.username});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
        userId: json['userId'],
        typeOfUser: json['typeOfUser'],
        username: json['username'],
      );
}
