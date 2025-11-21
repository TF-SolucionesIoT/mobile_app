import 'package:app_alerta_vital/features/auth/presentation/register/gender_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenderSelector extends ConsumerWidget {
  const GenderSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gender = ref.watch(genderNotifierProvider);

    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: "MALE",
          label: Text("Male"),
        ),
        ButtonSegment(
          value: "FEMALE",
          label: Text("Female"),
        ),
        ButtonSegment(
          value: "OTHER",
          label: Text("Other"),
        ),
      ],
      selected: {if (gender != null) gender},
      onSelectionChanged: (set) {
        ref.read(genderNotifierProvider.notifier).set(set.first);
      },
    );
  }
}