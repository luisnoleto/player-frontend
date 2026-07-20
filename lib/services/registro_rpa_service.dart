import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/app_exception.dart';
import '../models/registro_rpa.dart';

class RegistroRpaService {
  const RegistroRpaService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<RegistroRpa>> listarPendentes() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/rpa/registros/pendentes',
      );
      return (response.data ?? [])
          .map((item) => RegistroRpa.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }
}
