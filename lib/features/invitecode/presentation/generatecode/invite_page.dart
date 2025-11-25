import 'package:app_alerta_vital/features/invitecode/presentation/generatecode/invite_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class InvitePage extends ConsumerWidget {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inviteControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Generate Invite Code",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 30),

              state.code != null
                  ? Text(
                      "Your Code:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Container(),

              const SizedBox(height: 10),

              if (state.code != null)
                SelectableText(
                  state.code!,
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(height: 40),

              state.loading
                  ? CircularProgressIndicator()
                  : OutlinedButton.icon(
                      onPressed: () {
                        ref.read(inviteControllerProvider.notifier).generate();
                      },
                      icon: Icon(Icons.refresh, color: Colors.blue[600]),
                      label: Text(
                        "Generate Code",
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue.shade600, width: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                  ),
              if (state.code != null) ...[
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {
                    Share.share('My invite code is: ${state.code!}');
                  },
                  icon: Icon(Icons.share, color: Colors.blue[600]),
                  label: Text(
                    "Share",
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.shade600, width: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],

              if (state.error != null) ...[
                const SizedBox(height: 20),
                Text(state.error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
