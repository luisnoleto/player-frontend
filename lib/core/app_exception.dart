import 'package:dio/dio.dart';

class AppException implements Exception {
  const AppException({this.status, required this.message});

  final int? status;
  final String message;

  static AppException fromDioError(DioException error) {
    final response = error.response;
    final data = response?.data;

    if (data is Map) {
      final message = data['message'];
      final status = data['status'];
      if (message is String && message.isNotEmpty) {
        return AppException(
          status: status is int ? status : int.tryParse('$status'),
          message: message,
        );
      }
    }

    return const AppException(
      message: 'Não foi possível conectar ao servidor. Verifique sua conexão.',
    );
  }

  @override
  String toString() => message;
}
