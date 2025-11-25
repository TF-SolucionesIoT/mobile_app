import '../models/invite_model.dart';
import '../services/invite_service.dart';

class GenerateInviteCode {
  final InviteService service;

  GenerateInviteCode(this.service);

  Future<InviteModel> call() {
    return service.generate();
  }
}
