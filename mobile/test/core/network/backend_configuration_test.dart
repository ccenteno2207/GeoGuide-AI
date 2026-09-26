import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/core/network/backend_configuration.dart';

void main() {
  test('does not enable backend connectivity without a build-time URL', () {
    expect(BackendConfiguration.fromEnvironment(), isNull);
  });

  test('keeps a supplied HTTPS URL as configuration data', () {
    final configuration = BackendConfiguration(
      Uri(scheme: 'https', host: 'api.example.test'),
    );

    expect(configuration.baseUrl.scheme, 'https');
    expect(configuration.baseUrl.host, 'api.example.test');
  });
}
