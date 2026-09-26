import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/core/network/app_failure.dart';
import 'package:geoguide_ai/core/network/geoguide_http_client.dart';

void main() {
  group('mapDioException', () {
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
