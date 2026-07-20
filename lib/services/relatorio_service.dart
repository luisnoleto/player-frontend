import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/app_exception.dart';
import '../core/date_utils.dart';
import '../models/relatorio_consolidado.dart';

class RelatorioService {
  const RelatorioService(this._apiClient);

  final ApiClient _apiClient;

  Future<RelatorioConsolidado> gerarConsolidado(
    DateTime inicio,
    DateTime fim,
  ) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/relatorios/consolidado',
        queryParameters: {
          'inicio': formatApiDate(inicio),
          'fim': formatApiDate(fim),
        },
      );
      return RelatorioConsolidado.fromJson(response.data!);
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }
}
