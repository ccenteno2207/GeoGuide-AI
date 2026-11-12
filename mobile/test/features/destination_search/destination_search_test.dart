import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/core/network/backend_configuration.dart';
import 'package:geoguide_ai/core/network/geoguide_http_client.dart';
import 'package:geoguide_ai/features/destination_search/application/search_destinations.dart';
import 'package:geoguide_ai/features/destination_search/domain/destination_search_repository.dart';
import 'package:geoguide_ai/features/destination_search/domain/destination_search_result.dart';
import 'package:geoguide_ai/features/destination_search/infrastructure/dio_destination_search_repository.dart';
import 'package:geoguide_ai/features/destination_search/presentation/destination_search_sheet.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';

void main() {
  test(
    'Dio repository maps source attribution and verified coordinates',
    () async {
      RequestOptions? capturedRequest;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedRequest = options;
            handler.resolve(
              Response<Map<String, Object?>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'results': [
                    {
                      'id': 'catalog-id',
                      'name': 'Plaza de Armas de Canta',
                      'type': 'LANDMARK',
                      'administrativeContext': 'Lima, Canta',
                      'latitude': -11.4669625,
                      'longitude': -76.6247746,
                      'source': 'MINCETUR',
                      'sourceUrl': 'https://example.test/ficha',
                      'license': 'ODC-BY-1.0',
                      'attribution': 'Inventario MINCETUR',
                    },
                  ],
                },
              ),
            );
          },
        ),
      );
      final repository = DioDestinationSearchRepository(
        GeoGuideHttpClient(
          configuration: BackendConfiguration(
            Uri.parse('https://api.example.test'),
          ),
          dio: dio,
        ),
      );

      final results = await repository.searchByName('Canta');

      expect(capturedRequest?.path, '/api/v1/destinations/search');
      expect(capturedRequest?.data, {'query': 'Canta', 'limit': 10});
      expect(results.single.verifiedPoint?.latitude, -11.4669625);
      expect(results.single.sourceUrl, 'https://example.test/ficha');
      expect(results.single.license, 'ODC-BY-1.0');
      expect(results.single.attribution, 'Inventario MINCETUR');
    },
  );

  testWidgets('does not search while typing and trims submitted query', (
    tester,
  ) async {
    final repository = _FakeDestinationRepository();
    await _showSearch(tester, repository);

    await tester.enterText(
      find.byKey(const ValueKey('destination-search-query')),
      '  Canta   Perú  ',
    );
    expect(repository.queries, isEmpty);

    await tester.tap(find.byKey(const ValueKey('destination-search-submit')));
    await tester.pumpAndSettle();
    expect(repository.queries, ['Canta Perú']);
    expect(
      find.text('No encontramos destinos con ese nombre.'),
      findsOneWidget,
    );
  });

  testWidgets('keeps ambiguous results separate until explicit selection', (
    tester,
  ) async {
    final repository = _FakeDestinationRepository(
      results: [
        _result(
          id: 'lima-plaza',
          name: 'Plaza de Armas',
          context: 'Lima, Lima',
          latitude: -12.0464,
          longitude: -77.0428,
        ),
        _result(
          id: 'canta-plaza',
          name: 'Plaza de Armas',
          context: 'Canta, Lima',
          latitude: -11.475,
          longitude: -76.624,
        ),
      ],
    );
    RoutePoint? selected;
    await _showSearch(
      tester,
      repository,
      onSelected: (point) => selected = point,
    );
    await _submit(tester, 'Plaza de Armas');

    expect(find.textContaining('Lima, Lima'), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const ValueKey('destination-result-canta-plaza')),
    );
    expect(find.textContaining('Canta, Lima'), findsOneWidget);
    expect(selected, isNull);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('destination-result-canta-plaza')),
        matching: find.text('Seleccionar'),
      ),
    );
    expect(selected?.latitude, -11.475);
  });

  testWidgets('does not enable route selection without verified coordinates', (
    tester,
  ) async {
    final repository = _FakeDestinationRepository(
      results: [
        const DestinationSearchResult(
          id: 'unresolved',
          name: 'Canta',
          typeLabel: 'Localidad',
          geographicContext: 'Perú',
          provenanceLabel: 'Catálogo de prueba',
          verifiedPoint: null,
        ),
      ],
    );
    var selected = false;
    await _showSearch(tester, repository, onSelected: (_) => selected = true);
    await _submit(tester, 'Canta');

    final button = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const ValueKey('destination-result-unresolved')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
    expect(selected, isFalse);
  });

  testWidgets('shows an error with retry and retries the same query', (
    tester,
  ) async {
    final repository = _FakeDestinationRepository(failuresRemaining: 1);
    await _showSearch(tester, repository);
    await tester.enterText(
      find.byKey(const ValueKey('destination-search-query')),
      'Huacachina',
    );
    await tester.tap(find.byKey(const ValueKey('destination-search-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo buscar destinos. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(repository.queries, ['Huacachina', 'Huacachina']);
    expect(
      find.text('No encontramos destinos con ese nombre.'),
      findsOneWidget,
    );
  });

  test(
    'does not call repository for blank input and normalizes whitespace',
    () async {
      final repository = _FakeDestinationRepository();
      final search = SearchDestinations(repository);

      expect(await search('  \t  '), isEmpty);
      expect(repository.queries, isEmpty);
      await search('  Plaza   de   Ica ');
      expect(repository.queries, ['Plaza de Ica']);
    },
  );
}

Future<void> _showSearch(
  WidgetTester tester,
  _FakeDestinationRepository repository, {
  ValueChanged<RoutePoint>? onSelected,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DestinationSearchSheet(
          searchDestinations: SearchDestinations(repository),
          onDestinationSelected: onSelected ?? (_) {},
        ),
      ),
    ),
  );
}

Future<void> _submit(WidgetTester tester, String query) async {
  await tester.enterText(
    find.byKey(const ValueKey('destination-search-query')),
    query,
  );
  await tester.tap(find.byKey(const ValueKey('destination-search-submit')));
  await tester.pumpAndSettle();
}

DestinationSearchResult _result({
  required String id,
  required String name,
  required String context,
  required double latitude,
  required double longitude,
}) => DestinationSearchResult(
  id: id,
  name: name,
  typeLabel: 'Plaza',
  geographicContext: context,
  provenanceLabel: 'Catálogo de prueba',
  verifiedPoint: RoutePoint(latitude: latitude, longitude: longitude),
);

class _FakeDestinationRepository implements DestinationSearchRepository {
  _FakeDestinationRepository({
    this.results = const [],
    this.failuresRemaining = 0,
  });

  final List<DestinationSearchResult> results;
  int failuresRemaining;
  final List<String> queries = [];

  @override
  Future<List<DestinationSearchResult>> searchByName(String query) async {
    queries.add(query);
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw StateError('test-only failure');
    }
    return results;
  }
}
