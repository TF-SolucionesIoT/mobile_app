import 'package:app_alerta_vital/features/invitecode/presentation/confirmcode/confirm_code_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfirmCodePage extends ConsumerWidget {
  ConfirmCodePage({super.key});

  final TextEditingController codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(confirmCodeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Enter Invite Code')),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: codeCtrl,
              decoration: InputDecoration(
                labelText: 'Enter code',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            state.loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      ref
                          .read(confirmCodeControllerProvider.notifier)
                          .confirm(codeCtrl.text.trim());
                    },
                    child: const Text("Confirm"),
                  ),

            if (state.error != null) ...[
              const SizedBox(height: 20),
              Text(state.error!, style: TextStyle(color: Colors.red)),
            ],

            if (state.code != null) ...[
              const SizedBox(height: 20),
              Text(
                "Successfully linked!",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
