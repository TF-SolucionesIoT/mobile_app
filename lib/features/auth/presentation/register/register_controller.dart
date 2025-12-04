import 'package:app_alerta_vital/core/services/session_provider.dart';
import 'package:app_alerta_vital/features/auth/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'register_state.dart';

class RegisterController extends Notifier<RegisterState> {
  @override
  RegisterState build() {
    return RegisterState.initial();
  }

  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String gender,
    String username,
    String password,
    String confirmPassword,
  ) async {
    // Limpiar estado anterior
    state = state.copyWith(error: null);

    // Validaciones
    final validationError = _validateInputs(
      firstName,
      lastName,
      email,
      gender,
      username,
      password,
      confirmPassword,
    );

    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return;
    }

    final registerUser = ref.read(registerUserProvider);
    final session = ref.read(sessionServiceProvider);

    state = state.copyWith(loading: true, error: null);

    try {
      final tokens = await registerUser(
        firstName.trim(),
        lastName.trim(),
        email.trim(),
        gender,
        username.trim(),
        password,
        "2000-01-01",
      );

      // Verificar que los tokens no sean nulos
      if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
        throw Exception("Invalid tokens received from server");
      }

      await session.saveTokens(
        tokens.accessToken,
        tokens.refreshToken,
        tokens.userId,
        tokens.typeOfUser,
      );

      state = state.copyWith(loading: false, tokens: tokens);
    } catch (e) {
      // Mejorar mensaje de error
      String errorMessage = _parseErrorMessage(e.toString());
      state = state.copyWith(loading: false, error: errorMessage);
    }
  }

  String? _validateInputs(
    String firstName,
    String lastName,
    String email,
    String gender,
    String username,
    String password,
    String confirmPassword,
  ) {
    if (firstName.trim().isEmpty) {
      return "First name is required";
    }

    if (lastName.trim().isEmpty) {
      return "Last name is required";
    }

    if (email.trim().isEmpty) {
      return "Email is required";
    }

    if (!_isValidEmail(email)) {
      return "Please enter a valid email";
    }

    if (gender.isEmpty) {
      return "Please select your gender";
    }

    if (username.trim().isEmpty) {
      return "Username is required";
    }

    if (username.trim().length < 3) {
      return "Username must be at least 3 characters";
    }

    if (password.isEmpty) {
      return "Password is required";
    }

    if (password.length < 6) {
      return "Password must be at least 6 characters";
    }

    if (confirmPassword.isEmpty) {
      return "Please confirm your password";
    }

    if (password != confirmPassword) {
      return "Passwords do not match";
    }

    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  String _parseErrorMessage(String error) {
    // Limpiar mensajes de error técnicos
    if (error.contains("Exception:")) {
      error = error.replaceAll("Exception:", "").trim();
    }

    if (error.contains("SocketException")) {
      return "No internet connection. Please check your network.";
    }

    if (error.contains("TimeoutException")) {
      return "Connection timeout. Please try again.";
    }

    if (error.contains("FormatException")) {
      return "Invalid server response. Please try again.";
    }

    if (error.toLowerCase().contains("already exists")) {
      return "Username or email already exists";
    }

    if (error.toLowerCase().contains("invalid")) {
      return "Invalid credentials. Please check your information.";
    }

    // Si el error es muy largo, acortarlo
    if (error.length > 100) {
      return "Registration failed. Please try again.";
    }

    return error;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}