import 'package:dio/dio.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/core/network/app_failure.dart';
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

  testWidgets('debounces typing and trims the incremental query', (
    tester,
  ) async {
    final repository = _FakeDestinationRepository();
    await _showSearch(tester, repository);

    await tester.enterText(
      find.byKey(const ValueKey('destination-search-query')),
      '  Canta   Perú  ',
    );
    expect(repository.queries, isEmpty);
    await tester.pump(const Duration(milliseconds: 299));
    expect(repository.queries, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(repository.queries, ['Canta Perú']);
    expect(
      find.text('No encontramos destinos con ese nombre.'),
      findsOneWidget,
    );
  });

  testWidgets('submit while debounce is pending does not duplicate request', (
    tester,
  ) async {
    final repository = _FakeDestinationRepository();
    await _showSearch(tester, repository);
    await tester.enterText(
      find.byKey(const ValueKey('destination-search-query')),
      'Canta',
    );
    await tester.tap(find.byKey(const ValueKey('destination-search-submit')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(repository.queries, ['Canta']);
  });

  testWidgets('normalized-equivalent edits do not dispatch another request', (
    tester,
  ) async {
    final repository = _FakeDestinationRepository(
      results: [
        _result(
          id: 'canta',
          name: 'Canta',
          context: 'Lima',
          latitude: -11.475,
          longitude: -76.624,
        ),
      ],
    );
    await _showSearch(tester, repository);
    final field = find.byKey(const ValueKey('destination-search-query'));
    await tester.enterText(field, 'Canta');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.enterText(field, '  Canta   ');
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.queries, ['Canta']);
    expect(find.text('Canta'), findsOneWidget);
  });

  testWidgets('debounce discards stale response from an older query', (
    tester,
  ) async {
    final first = Completer<List<DestinationSearchResult>>();
    final second = Completer<List<DestinationSearchResult>>();
    final repository = _FakeDestinationRepository(
      search: (query) => query == 'Can' ? first.future : second.future,
    );
    await _showSearch(tester, repository);
    final field = find.byKey(const ValueKey('destination-search-query'));
    await tester.enterText(field, 'Can');
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.queries, ['Can']);
    await tester.enterText(field, 'Canta');
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.queries, ['Can', 'Canta']);
    second.complete([
      _result(
        id: 'new-canta',
        name: 'Plaza de Armas de Canta',
        context: 'Canta, Lima',
        latitude: -11.475,
        longitude: -76.624,
      ),
    ]);
    await tester.pump();
    expect(find.text('Plaza de Armas de Canta'), findsOneWidget);
    first.complete([
      _result(
        id: 'old-can',
        name: 'Resultado obsoleto',
        context: 'Perú',
        latitude: -12,
        longitude: -77,
      ),
    ]);
    await tester.pump();
    expect(find.text('Plaza de Armas de Canta'), findsOneWidget);
    expect(find.text('Resultado obsoleto'), findsNothing);
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

  testWidgets('shows an offline state with retry', (tester) async {
    final repository = _FakeDestinationRepository(
      failuresRemaining: 1,
      failure: const AppFailure(AppFailureType.backendUnavailable),
    );
    await _showSearch(tester, repository);
    await tester.enterText(
      find.byKey(const ValueKey('destination-search-query')),
      'Huacachina',
    );
    await tester.tap(find.byKey(const ValueKey('destination-search-submit')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Sin conexión o servicio no disponible. Comprueba la conexión e inténtalo de nuevo.',
      ),
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
    this.failure,
    this.search,
  });

  final List<DestinationSearchResult> results;
  int failuresRemaining;
  final Object? failure;
  final Future<List<DestinationSearchResult>> Function(String query)? search;
  final List<String> queries = [];

  @override
  Future<List<DestinationSearchResult>> searchByName(String query) async {
    queries.add(query);
    if (search case final handler?) return handler(query);
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw failure ?? StateError('test-only failure');
    }
    return results;
  }
}
