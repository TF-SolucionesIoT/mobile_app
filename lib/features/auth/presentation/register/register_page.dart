import 'package:app_alerta_vital/features/auth/auth.dart';
import 'package:app_alerta_vital/features/auth/presentation/register/gender_notifier.dart';
import 'package:app_alerta_vital/features/auth/presentation/ui/radio_button_gender.dart';
import 'package:app_alerta_vital/features/auth/presentation/register/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerWidget {
  RegisterPage({super.key});

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  final Color primaryColor = const Color(0xFF5A9DE0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<RegisterState>(registerControllerProvider, (prev, next) {
      if (next.tokens != null && !next.loading) {
        context.go('/home');
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    final gender = ref.watch(genderNotifierProvider);
    final state = ref.watch(registerControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 120),

            Text(
              "Create Account",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // First Name
            TextField(
              controller: firstNameCtrl,
              decoration: _input("First Name"),
            ),

            const SizedBox(height: 20),

            // Last Name
            TextField(
              controller: lastNameCtrl,
              decoration: _input("Last Name"),
            ),

            const SizedBox(height: 20),

            // Gender selector
            GenderSelector(),

            const SizedBox(height: 20),

            // Email
            TextField(
              controller: emailCtrl,
              decoration: _input("Email"),
            ),

            const SizedBox(height: 20),

            // Username
            TextField(
              controller: usernameCtrl,
              decoration: _input("Username"),
            ),

            const SizedBox(height: 20),

            // Password
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: _input("Password"),
            ),

            const SizedBox(height: 20),

            // Confirm Password
            TextField(
              controller: confirmPasswordCtrl,
              obscureText: true,
              decoration: _input("Confirm Password"),
            ),

            const SizedBox(height: 10),

            // Go to Login
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                "Already have an account? Login",
                style: TextStyle(color: primaryColor),
              ),
            ),

            const SizedBox(height: 20),

            // Register button
            state.loading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      ref.read(registerControllerProvider.notifier).register(
                            firstNameCtrl.text,
                            lastNameCtrl.text,
                            emailCtrl.text,
                            gender ?? "",
                            usernameCtrl.text,
                            passwordCtrl.text,
                            confirmPasswordCtrl.text,
                          );
                    },
                    child: const Text(
                      'Register',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),

            const SizedBox(height: 10),

            if (state.error != null)
              Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  // Reusable input decoration
  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: primaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: const Color.fromARGB(255, 60, 115, 170), width: 2),
      ),
    );
  }
}
