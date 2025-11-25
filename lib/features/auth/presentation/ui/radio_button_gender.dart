import 'package:app_alerta_vital/features/auth/presentation/register/gender_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenderSelector extends ConsumerWidget {
  const GenderSelector({super.key});

  final Color primaryColor = const Color(0xFF5A9DE0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gender = ref.watch(genderNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _genderButton("MALE", "Male", gender, ref),
            _genderButton("FEMALE", "Female", gender, ref),
            _genderButton("OTHER", "Other", gender, ref),
          ],
        ),
      ],
    );
  }

  Widget _genderButton(String value, String label, String? gender, WidgetRef ref) {
    final bool isSelected = gender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(genderNotifierProvider.notifier).set(value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.white,
            borderRadius: isSelected ? BorderRadius.circular(20) : BorderRadius.circular(10),
            border: Border.all(
              color: primaryColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
