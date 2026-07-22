import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/app_exception.dart';
import '../core/constants.dart';
import '../models/auth.dart';

class AuthService {
  const AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<UsuarioAutenticado> login(String login, String senha) async {
    try {
      final response = await _apiClient.dio.postUri<Map<String, dynamic>>(
        Uri.parse('$apiServerUrl/auth/login'),
        data: {'login': login, 'senha': senha},
      );
      return UsuarioAutenticado.fromJson(response.data!);
    } on DioException catch (error) {
      throw AppException.fromDioError(error);
    }
  }
}
