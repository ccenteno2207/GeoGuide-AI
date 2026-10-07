import 'package:dio/dio.dart';

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/core/network/app_failure.dart';
import 'package:geoguide_ai/core/network/geoguide_http_client.dart';

void main() {
  group('mapDioException', () {
    test(
      'TLS and authorization failures never become cacheable network failures',
      () {
        final request = RequestOptions(path: '/api/v1/routes/discover');
        for (final error in [
          DioException(
            requestOptions: request,
            type: DioExceptionType.badCertificate,
          ),
          DioException(
            requestOptions: request,
            type: DioExceptionType.connectionError,
            error: const HandshakeException(),
          ),
          DioException(
            requestOptions: request,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: request, statusCode: 401),
          ),
          DioException(
            requestOptions: request,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: request, statusCode: 403),
          ),
        ]) {
          expect(mapDioException(error).type, AppFailureType.security);
        }
      },
    );
    test('maps a connection error without exposing connection details', () {
      final failure = mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/routes/plan'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(failure.type, AppFailureType.backendUnavailable);
      expect(failure.userMessage, 'Servicio no disponible');
    });

    test('maps a timeout to a safe application failure', () {
      final failure = mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/routes/plan'),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(failure.type, AppFailureType.timeout);
    });

    test('maps the backend no-route code', () {
      final failure = mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/routes/plan'),
          type: DioExceptionType.badResponse,
          response: Response<Object?>(
            requestOptions: RequestOptions(path: '/api/v1/routes/plan'),
            statusCode: 404,
            data: {'code': 'NO_ROUTE_FOUND'},
          ),
        ),
      );

      expect(failure.type, AppFailureType.noRouteFound);
    });
  });
}
