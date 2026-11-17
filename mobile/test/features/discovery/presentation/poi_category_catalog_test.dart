import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_presentation.dart';

void main() {
  test(
    'maps all fifteen current taxonomy codes to distinct Material icons',
    () {
      const expectedCodes = {
        'WATERFALL',
        'LAGOON',
        'MOUNTAIN',
        'FOREST',
        'BEACH',
        'MUSEUM',
        'ARCHAEOLOGICAL_SITE',
        'MONUMENT',
        'HISTORIC_CHURCH',
        'VIEWPOINT',
        'FUEL',
        'HEALTH',
        'FOOD',
        'LODGING',
        'OTHER',
      };

      expect(poiCategoryCatalog.keys.toSet(), expectedCodes);
      expect(
        poiCategoryCatalog.values.map((value) => value.label).toSet(),
        hasLength(15),
      );
      expect(
        poiCategoryCatalog.values.map((value) => value.icon).toSet(),
        hasLength(15),
      );
      expect(
        poiCategoryCatalog.values.map((value) => value.icon),
        isNot(contains(Icons.trip_origin)),
      );
      expect(
        poiCategoryCatalog.values.map((value) => value.icon),
        isNot(contains(Icons.location_on)),
      );
      expect(
        poiCategoryCatalog.values.map((value) => value.icon),
        isNot(contains(Icons.my_location)),
      );
      expect(discoveryCategoryCodes, hasLength(10));
      expect(
        discoveryCategoryCodes.every(poiCategoryCatalog.containsKey),
        isTrue,
      );
      expect(
        poiCategoryCatalog.keys.where(
          (code) => !discoveryCategoryCodes.contains(code),
        ),
        containsAll(['FUEL', 'HEALTH', 'FOOD', 'LODGING', 'OTHER']),
      );
    },
  );

  test('uses distinct water, terrain, beach and viewpoint silhouettes', () {
    expect(poiCategoryIcon('WATERFALL'), Icons.water_drop);
    expect(poiCategoryIcon('LAGOON'), Icons.water);
    expect(poiCategoryIcon('MOUNTAIN'), Icons.terrain);
    expect(poiCategoryIcon('BEACH'), Icons.beach_access);
    expect(poiCategoryIcon('VIEWPOINT'), Icons.visibility);
  });

  test(
    'unknown visual codes use the generic fallback without adding taxonomy',
    () {
      expect(poiCategoryPresentation('UNRECOGNIZED').label, 'Lugar de interés');
      expect(poiCategoryIcon('UNRECOGNIZED'), Icons.category);
      expect(poiCategoryCatalog.containsKey('UNRECOGNIZED'), isFalse);
      expect(friendlyPoiCategory('FUEL'), 'Combustible');
      expect(discoveryCategoryCodes, isNot(contains('FUEL')));
    },
  );

  testWidgets(
    'renders the complete icon catalog with bundled Material glyphs',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Wrap(
              children: [
                for (final entry in poiCategoryCatalog.entries)
                  Icon(entry.value.icon, key: ValueKey(entry.key)),
              ],
            ),
          ),
        ),
      );

      for (final code in poiCategoryCatalog.keys) {
        expect(find.byKey(ValueKey(code)), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );
}
