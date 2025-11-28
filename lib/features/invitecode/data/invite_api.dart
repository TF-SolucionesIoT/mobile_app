
import 'package:app_alerta_vital/core/services/dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class InviteApi {
  final Dio dio;
  InviteApi(this.dio);

  Future<String> generateInviteCode() async {
    final response = await dio.post('/invite/generate');

    if (response.statusCode == 200) {
      return response.data["code"];
    } else {
      throw Exception("Error ${response.statusCode}: ${response.data}");
    }
  }

  Future<String> confirmCode(String code) async {
    final response = await dio.post('/invite/use/$code');

    if (response.statusCode == 200) {
      return "vinculated";
    } else {
      throw Exception("Error ${response.statusCode}: ${response.data}");
    }
  }

}

// Provider de InviteApi
final inviteApiProvider = Provider<InviteApi>((ref) {
  final dio = ref.read(dioProvider);
  return InviteApi(dio);
});
