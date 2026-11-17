import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_detail_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_preview_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_result_card.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_thumbnail.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';

const _expectedIds = <String>[
  '02000000-0000-0000-0000-000000000001',
  '02000000-0000-0000-0000-000000000002',
  '02000000-0000-0000-0000-000000000003',
  '02000000-0000-0000-0000-000000000004',
  '02000000-0000-0000-0000-000000000005',
];

DiscoveryPoi _poi(String id) => DiscoveryPoi(
  id: id,
  name: 'POI $id',
  category: 'MONUMENT',
  location: const RoutePoint(latitude: -12, longitude: -77),
  distanceToRouteMeters: 100,
  routeProgress: .5,
  reasonCodes: const [],
);

void main() {
  test('catalog is closed, stable-ID keyed and one-to-one', () {
    expect(
      PoiLocalDemoImageCatalog.assetsByPoiId.keys.toSet(),
      _expectedIds.toSet(),
    );
    final paths = PoiLocalDemoImageCatalog.assetsByPoiId.values.toList();
    expect(paths.toSet(), hasLength(5));
    for (final id in _expectedIds) {
      expect(
        PoiLocalDemoImageCatalog.assetsByPoiId[id],
        'assets/demo/poi_images/$id.png',
      );
    }
    expect(PoiLocalDemoImageCatalog.assetsByPoiId['unknown-id'], isNull);
  });

  testWidgets(
    'standard builds use placeholders and never request demo assets',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoiResultCard(
              poi: _poi(_expectedIds.first),
              onPressed: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      );
      expect(find.byType(Image), findsNothing);
      expect(PoiLocalDemoImageCatalog.assetFor(_expectedIds.first), isNull);
    },
    skip: internalPoiImagesDemoEnabled,
  );

  testWidgets('demo assets load by ID in card, Preview and Detail', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final size in [
      const Size(320, 480),
      const Size(360, 640),
      const Size(640, 360),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      for (final id in _expectedIds) {
        final poi = _poi(id);
        final asset = 'assets/demo/poi_images/$id.png';
        final bytes = await rootBundle.load(asset);
        expect(bytes.lengthInBytes, greaterThan(8));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PoiResultCard(
                poi: poi,
                onPressed: () {},
                onViewDetails: () {},
              ),
            ),
          ),
        );
        final cardImage = tester.widget<Image>(find.byType(Image));
        expect(_imageAsset(tester), asset);
        expect(cardImage.fit, BoxFit.cover);
        expect(
          cardImage.semanticLabel,
          'Fotografía de referencia de ${poi.name}',
        );
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PoiPreviewSheet(poi: poi)),
          ),
        );
        expect(_imageAsset(tester), asset);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PoiDetailSheet(poi: poi)),
          ),
        );
        expect(_imageAsset(tester), asset);
        expect(tester.takeException(), isNull);
      }
    }
  }, skip: !internalPoiImagesDemoEnabled);

  testWidgets('missing demo asset falls back to the existing placeholder', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: DefaultAssetBundle(
          bundle: _FailingAssetBundle(),
          child: Scaffold(
            body: PoiResultCard(
              poi: _poi(_expectedIds.first),
              onPressed: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('Imagen no disponible')), findsWidgets);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  }, skip: !internalPoiImagesDemoEnabled);

  testWidgets('unknown POI keeps the established placeholder', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PoiResultCard(
            poi: _poi('unknown-id'),
            onPressed: () {},
            onViewDetails: () {},
          ),
        ),
      ),
    );
    expect(find.byType(Image), findsNothing);
    expect(find.bySemanticsLabel(RegExp('Imagen no disponible')), findsWidgets);
    semantics.dispose();
  });
}

String _imageAsset(WidgetTester tester) =>
    tester.widget<Image>(find.byType(Image)).image is AssetImage
    ? (tester.widget<Image>(find.byType(Image)).image as AssetImage).assetName
    : throw StateError('Demo image did not use an AssetImage');

class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) =>
      Future<ByteData>.error(StateError('Test-only missing asset: $key'));
}
