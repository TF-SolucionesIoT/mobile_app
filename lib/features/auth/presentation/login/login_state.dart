import '../../domain/models/auth_tokens.dart';


class LoginState {
  final bool loading;
  final AuthTokens? tokens;
  final String? error;

  LoginState({this.loading = false, this.tokens, this.error});

  factory LoginState.initial() => LoginState();

  LoginState copyWith({bool? loading, AuthTokens? tokens, String? error}) {
    return LoginState(
      loading: loading ?? this.loading,
      tokens: tokens ?? this.tokens,
      error: error,
    );
  }
}