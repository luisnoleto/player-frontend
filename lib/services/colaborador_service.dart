import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/app_exception.dart';
import '../models/colaborador.dart';

class ColaboradorService {
  const ColaboradorService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Colaborador>> listarAtivos() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>('/colaboradores');
      return (response.data ?? [])
          .map((item) => Colaborador.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }

  Future<Colaborador> buscarPorId(int id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/colaboradores/$id');
      return Colaborador.fromJson(response.data!);
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }

  Future<Colaborador> criar(ColaboradorRequest request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/colaboradores',
        data: request.toJson(),
      );
      return Colaborador.fromJson(response.data!);
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }

  Future<void> inativar(int id) async {
    try {
      await _apiClient.dio.delete<void>('/colaboradores/$id');
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }
}
