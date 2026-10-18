import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/discovery/application/offline_discovery.dart';
import 'package:geoguide_ai/features/discovery/infrastructure/route_discovery_response_mapper.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_detail_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_preview_sheet.dart';

import 'offline_cache_test.dart' as fixtures;
import 'offline_ui_test.dart' show MemoryStore;
import 'ui2_experience_test.dart' show CountingSource, syntheticSnapshot;
import '../tracking/b1_widget_test.dart' show FakeSession;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => Directory.systemTemp.path,
        );
  });
  test('mapping preserves source language and accents without translation', () {
    for (final (name, description) in [
      ('Museo Ámbar', 'Descripción histórica: río y arqueología.'),
      ('Amber Museum', 'Historical description of the valley.'),
    ]) {
      final poi = const RouteDiscoveryResponseMapper().fromJson({
        'results': [
          {
            'id': 'TEST_ONLY',
            'name': name,
            'description': description,
            'category': 'MUSEUM',
            'location': {'latitude': -12.0, 'longitude': -77.0},
            'distanceToRouteMeters': 50,
            'routeProgress': .5,
            'reasonCodes': ['NEAR_ROUTE'],
          },
        ],
      }).single;
      expect(poi.name, name);
      expect(poi.description, description);
    }
  });

  testWidgets(
    'diagnostic: Spanish POI text survives Preview/Detail under current app locale',
    (tester) async {
      final semantics = tester.ensureSemantics();
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.localeTestValue = const Locale('es', 'PE');
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      final snapshot = syntheticSnapshot();
      final offline = OfflineDiscovery(
        source: CountingSource(),
        store: MemoryStore()..value = snapshot,
        backendContext: snapshot.query.backendContext,
        now: () => fixtures.captured,
      );
      await tester.pumpWidget(
        GeoGuideApp(routeSession: FakeSession(), offlineDiscovery: offline),
      );
      await tester.pumpAndSettle();
      // A device locale alone cannot select Spanish: the current app supports
      // only the default en_US. This is diagnostic evidence, not a voice test.
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.supportedLocales, const [Locale('en', 'US')]);
      expect(app.localizationsDelegates, isNull);
      await tester.tap(find.byTooltip('Vista previa de Museo Ámbar'));
      await tester.pumpAndSettle();
      expect(find.byType(PoiPreviewSheet), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Vista previa de Museo Ámbar')),
        findsWidgets,
      );
      expect(
        Localizations.localeOf(tester.element(find.byType(PoiPreviewSheet))),
        const Locale('en', 'US'),
      );
      await tester.ensureVisible(find.text('Ver detalle'));
      await tester.tap(find.text('Ver detalle'));
      await tester.pumpAndSettle();
      expect(find.byType(PoiDetailSheet), findsOneWidget);
      expect(find.text(snapshot.pois.first.description!), findsOneWidget);
      final textNode = tester
          .getSemantics(find.text(snapshot.pois.first.description!))
          .getSemanticsData();
      expect(textNode.label, contains(snapshot.pois.first.description!));
      // No explicit per-text speech locale is supplied. App localizations and
      // the actual voice chosen by TalkBack are separate observations.
      expect(textNode.locale, isNull);
      await tester.ensureVisible(find.text('Volver'));
      expect(find.text('Volver').hitTestable(), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    },
  );
}
