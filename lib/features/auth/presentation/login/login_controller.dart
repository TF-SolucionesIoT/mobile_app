import 'package:app_alerta_vital/core/services/session_provider.dart';
import 'package:app_alerta_vital/core/services/type_of_user_provider.dart';
import 'package:app_alerta_vital/features/auth/auth.dart';
import 'package:app_alerta_vital/features/auth/presentation/login/login_state.dart';
import 'package:app_alerta_vital/features/home/presentation/home_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() {
    return LoginState.initial();
  }

  Future<void> login(String username, String password) async {
    final session = ref.read(sessionServiceProvider);
    final loginUser = ref.read(loginUserProvider);

    state = state.copyWith(loading: true, error: null);

    try {
      final tokens = await loginUser(username, password);
      await session.saveTokens(tokens.accessToken, tokens.refreshToken, tokens.userId, tokens.typeOfUser);
      state = state.copyWith(loading: false, tokens: tokens);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final session = ref.read(sessionServiceProvider);

    await session.logout();

    ref.invalidate(userTypeProvider);
    ref.invalidate(sessionServiceProvider);
    ref.invalidate(homeControllerProvider);


    state = LoginState.initial();
  }
}
