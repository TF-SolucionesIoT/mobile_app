import 'package:app_alerta_vital/core/services/dio_provider.dart';
import 'package:app_alerta_vital/features/invitecode/data/invite_api.dart';
import 'package:app_alerta_vital/features/invitecode/domain/services/invite_service.dart';
import 'package:app_alerta_vital/features/invitecode/domain/usecases/generate_invite_code.dart';
import 'package:app_alerta_vital/features/invitecode/presentation/generatecode/invite_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final inviteApiProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return InviteApi(dio);
});
final inviteServiceProvider =
    Provider((ref) => InviteService(ref.read(inviteApiProvider)));

final generateInviteProvider =
    Provider((ref) => GenerateInviteCode(ref.read(inviteServiceProvider)));

final inviteControllerProvider =
    NotifierProvider<InviteController, InviteState>(InviteController.new);

class InviteController extends Notifier<InviteState> {
  @override
  InviteState build() => InviteState.initial();

  Future<void> generate() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final usecase = ref.read(generateInviteProvider);
      final result = await usecase();

      state = state.copyWith(
        loading: false,
        code: result.code,
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
