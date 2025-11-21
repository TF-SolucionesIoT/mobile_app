import 'package:app_alerta_vital/features/auth/auth.dart';
import 'package:app_alerta_vital/features/auth/presentation/register/gender_notifier.dart';
import 'package:app_alerta_vital/features/auth/presentation/register/register_state.dart';
import 'package:app_alerta_vital/features/auth/presentation/ui/radio_button_gender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerWidget{
  RegisterPage({super.key});

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final genderProvider = Provider<String?>((ref) => null);

    final Color primaryColor = const Color(0xFF5A9DE0);


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.listen<RegisterState>(registerControllerProvider, (prev, next) {
      if (next.tokens != null && !next.loading) {
        context.go('/home');
      }

      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    final state = ref.watch(registerControllerProvider);
    final gender = ref.watch(genderNotifierProvider);

    if (state.tokens != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameCtrl,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameCtrl,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            GenderSelector(),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: usernameCtrl,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: confirmPasswordCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm Password'),
            ),
            // Registrar
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                "Already have an account? Login",
                style: TextStyle(color: primaryColor),
              ),
            ),
            SizedBox(height: 20),
            state.loading
                ? CircularProgressIndicator()
                : ElevatedButton(
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
                    child: Text('Register'),
                  ),
            if (state.error != null)
              Text(state.error!, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}