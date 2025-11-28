import 'package:app_alerta_vital/features/invitecode/domain/usecases/use_invite_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'confirm_code_state.dart';

import 'package:app_alerta_vital/core/services/dio_provider.dart';
import 'package:app_alerta_vital/features/invitecode/data/invite_api.dart';
import 'package:app_alerta_vital/features/invitecode/domain/services/invite_service.dart';


final inviteApiProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return InviteApi(dio);
});

final inviteServiceProvider =
    Provider((ref) => InviteService(ref.read(inviteApiProvider)));

final useCodeProvider =
    Provider((ref) => UseInviteCode(ref.read(inviteServiceProvider)));


final confirmCodeControllerProvider =
    NotifierProvider<ConfirmCodeController, ConfirmCodeState>(
        ConfirmCodeController.new);

class ConfirmCodeController extends Notifier<ConfirmCodeState> {
  @override
  ConfirmCodeState build() => ConfirmCodeState.initial();

  Future<void> confirm(String code) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final usecase = ref.read(useCodeProvider);
      final result = await usecase(code);

      state = state.copyWith(
        loading: false,
        code: result, // "vinculated"
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }
}
