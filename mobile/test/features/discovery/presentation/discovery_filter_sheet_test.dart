import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/discovery/presentation/discovery_filter_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_presentation.dart';

void main() {
  testWidgets('shows only Discovery categories with multi-select and Apply', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: DiscoveryFilterSheet(appliedCategories: {...discoveryCategoryCodes})),
    ));
    expect(find.text('Catarata'), findsOneWidget);
    expect(find.text('Combustible'), findsNothing);
    expect(find.text('Otros'), findsNothing);
    await tester.tap(find.text('Catarata'));
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
  });

  testWidgets('keeps filter actions readable with large text', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: const MaterialApp(
          home: Scaffold(
            body: DiscoveryFilterSheet(appliedCategories: {...discoveryCategoryCodes}),
          ),
        ),
      ),
    );

    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Restablecer'), findsOneWidget);
    expect(find.text('Aplicar'), findsOneWidget);

    await tester.ensureVisible(find.text('Restablecer'));
    await tester.tap(find.text('Restablecer'));
    await tester.pumpAndSettle();
  });
}
