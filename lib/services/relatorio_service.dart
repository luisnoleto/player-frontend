import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/app_exception.dart';
import '../core/date_utils.dart';
import '../models/relatorio_consolidado.dart';
import '../models/horas_trabalhadas_equipe.dart';

class RelatorioService {
  const RelatorioService(this._apiClient);

  final ApiClient _apiClient;

  Future<HorasTrabalhadasEquipe> listarHorasPorColaborador() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/relatorios/horas-por-colaborador',
      );
      return HorasTrabalhadasEquipe.fromJson(response.data!);
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }

  Future<RelatorioConsolidado> gerarConsolidado({
    int? colaboradorId,
    DateTime? inicio,
    DateTime? fim,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/relatorios/consolidado',
        queryParameters: <String, dynamic>{
          'colaboradorId': ?colaboradorId,
          if (inicio != null) 'inicio': formatApiDate(inicio),
          if (fim != null) 'fim': formatApiDate(fim),
        },
      );
      return RelatorioConsolidado.fromJson(response.data!);
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }
}
