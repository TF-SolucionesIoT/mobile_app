import 'package:app_alerta_vital/features/auth/data/auth_api.dart';
import 'package:app_alerta_vital/features/auth/data/auth_repository.dart';
import 'package:app_alerta_vital/features/auth/domain/usecases/login_user.dart';
import 'package:app_alerta_vital/features/auth/domain/usecases/register_user.dart';
import 'package:app_alerta_vital/features/auth/presentation/login/login_controller.dart';
import 'package:app_alerta_vital/features/auth/presentation/login/login_state.dart';
import 'package:app_alerta_vital/features/auth/presentation/register/register_controller.dart';
import 'package:app_alerta_vital/features/auth/presentation/register/register_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// API
final authApiProvider = Provider((ref) => AuthApi());

// Repository
final authRepositoryProvider = Provider((ref) => AuthRepository(ref.read(authApiProvider)));

// UseCase
final loginUserProvider = Provider((ref) => LoginUser(ref.read(authRepositoryProvider)));
final registerUserProvider = Provider((ref) => RegisterUser(ref.read(authRepositoryProvider)));


// Controller
final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  () => LoginController(),
);

final registerControllerProvider = NotifierProvider<RegisterController, RegisterState>(
  () => RegisterController(),
);



