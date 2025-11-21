import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenderNotifier extends Notifier<String?> {
  @override
  String? build() => "MALE";

  void set(String gender) => state = gender;
}

final genderNotifierProvider =
    NotifierProvider<GenderNotifier, String?>(() => GenderNotifier());