import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/app_exception.dart';
import '../models/atividade.dart';

class AtividadeService {
  const AtividadeService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Atividade>> listarTodas() => _listar('/atividades');

  Future<List<Atividade>> listarPorColaborador(int colaboradorId) =>
      _listar('/atividades/colaborador/$colaboradorId');

  Future<List<Atividade>> _listar(String path) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(path);
      return (response.data ?? [])
          .map((item) => Atividade.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }
}
