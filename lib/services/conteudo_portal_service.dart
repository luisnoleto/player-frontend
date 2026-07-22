import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/app_exception.dart';
import '../models/conteudo_portal.dart';

class ConteudoPortalService {
  const ConteudoPortalService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ConteudoPortal>> listar() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/rpa/conteudos',
      );
      return (response.data ?? [])
          .map((item) => ConteudoPortal.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }
}
