import 'package:app_alerta_vital/features/invitecode/domain/services/invite_service.dart';

class UseInviteCode {
  final InviteService inviteService;

  UseInviteCode( this.inviteService);

  Future<String> call(String code) {
    return inviteService.confirm(code);
  }
}