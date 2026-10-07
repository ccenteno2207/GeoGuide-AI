import 'dart:io';

import 'package:dio/dio.dart';

import 'app_failure.dart';
import 'backend_configuration.dart';

class GeoGuideHttpClient {
  GeoGuideHttpClient({required BackendConfiguration configuration, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: configuration.baseUrl.toString(),
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              responseType: ResponseType.json,
            ),
          );

  final Dio _dio;

  Future<Map<String, Object?>> postJson({
    required String path,
    required Map<String, Object?> body,
  }) async {
    try {
      final response = await _dio.post<Object?>(path, data: body);
      final data = response.data;
      if (data is! Map) {
        throw const AppFailure(AppFailureType.invalidResponse);
      }
      return data.map((key, value) => MapEntry(key.toString(), value));
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

AppFailure mapDioException(DioException error) {
  if (error.type == DioExceptionType.badCertificate ||
      error.error is HandshakeException ||
      error.error is TlsException ||
      error.response?.statusCode == 401 ||
      error.response?.statusCode == 403) {
    return const AppFailure(AppFailureType.security);
  }
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout) {
    return const AppFailure(AppFailureType.timeout);
  }

  if (error.type == DioExceptionType.connectionError) {
    return const AppFailure(AppFailureType.backendUnavailable);
  }

  final response = error.response;
  final data = response?.data;
  final code = data is Map ? data['code'] : null;
  if (response?.statusCode == 404 && code == 'NO_ROUTE_FOUND') {
    return const AppFailure(AppFailureType.noRouteFound);
  }

  return switch (response?.statusCode) {
    400 => const AppFailure(AppFailureType.validation),
    502 || 503 => const AppFailure(AppFailureType.backendUnavailable),
    504 => const AppFailure(AppFailureType.timeout),
    500 || 501 => const AppFailure(AppFailureType.server),
    _ => const AppFailure(AppFailureType.invalidResponse),
  };
}
