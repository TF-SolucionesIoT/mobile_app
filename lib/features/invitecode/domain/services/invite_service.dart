import '../models/invite_model.dart';
import '../../data/invite_api.dart';

class InviteService {
  final InviteApi api;

  InviteService(this.api);

  Future<InviteModel> generate() async {
    final code = await api.generateInviteCode();
    return InviteModel(code: code);
  }
}
