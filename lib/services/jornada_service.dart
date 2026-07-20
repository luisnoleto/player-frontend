import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/app_exception.dart';
import '../core/date_utils.dart';
import '../models/jornada_detalhe.dart';
import '../models/jornada_resumo.dart';

class JornadaService {
  const JornadaService(this._apiClient);

  final ApiClient _apiClient;

  Future<JornadaDetalhe> iniciar(IniciarJornadaRequest request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/jornadas',
        data: request.toJson(),
      );
      return JornadaDetalhe.fromJson(response.data!);
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }

  Future<JornadaDetalhe> encerrar(
    int jornadaId,
    EncerrarJornadaRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        '/jornadas/$jornadaId/encerrar',
        data: request.toJson(),
      );
      return JornadaDetalhe.fromJson(response.data!);
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }

  Future<JornadaDetalhe> buscarDetalhe(int id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/jornadas/$id');
      return JornadaDetalhe.fromJson(response.data!);
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }

  Future<List<JornadaResumo>> buscarHistorico(int colaboradorId) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/jornadas/colaborador/$colaboradorId',
      );
      return (response.data ?? [])
          .map((item) => JornadaResumo.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }

  Future<List<JornadaResumo>> listarComFiltros({
    String? status,
    int? colaboradorId,
    DateTime? inicio,
    DateTime? fim,
  }) async {
    final queryParameters = <String, dynamic>{
      'status': ?status,
      'colaboradorId': ?colaboradorId,
      if (inicio != null) 'inicio': formatApiDate(inicio),
      if (fim != null) 'fim': formatApiDate(fim),
    };

    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        '/jornadas',
        queryParameters: queryParameters,
      );
      return (response.data ?? [])
          .map((item) => JornadaResumo.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }
}
