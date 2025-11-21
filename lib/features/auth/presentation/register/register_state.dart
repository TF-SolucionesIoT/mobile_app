import 'package:app_alerta_vital/features/auth/domain/models/auth_tokens.dart';

class RegisterState {
  final bool loading;
  final String? error;
  final AuthTokens? tokens;

  RegisterState(
    {this.loading = false, this.error, this.tokens});
  factory RegisterState.initial() => RegisterState();

  RegisterState copyWith({bool? loading, String? error, AuthTokens? tokens}) {
    return RegisterState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      tokens: tokens ?? this.tokens,
    );
  }

}