import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'constants.dart';

class ApiClient {
  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401 && _token != null) {
            clearToken();
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: false, responseBody: false),
      );
    }
  }

  final Dio dio;
  String? _token;
  VoidCallback? onUnauthorized;

  void setToken(String token) => _token = token;

  void clearToken() => _token = null;
}
