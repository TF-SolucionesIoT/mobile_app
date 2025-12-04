import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'access_api_service.dart';

final accessApiServiceProvider = Provider<AccessApiService>((ref) {
  return AccessApiService();
});