import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/core/network/backend_configuration.dart';

void main() {
  test('accepts an externally supplied HTTP pilot endpoint', () {
    final configuration = BackendConfiguration.tryParse(
      'http://geoguide.getcom.pe:1980',
    );

    expect(configuration?.baseUrl.toString(), 'http://geoguide.getcom.pe:1980');
  });

  test('rejects an absent or unsupported backend endpoint', () {
    expect(BackendConfiguration.tryParse(''), isNull);
    expect(BackendConfiguration.tryParse('geoguide.getcom.pe'), isNull);
    expect(BackendConfiguration.tryParse('ftp://geoguide.getcom.pe'), isNull);
  });
}
