import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';

void main() {
  testWidgets('renders the GeoGuide AI bootstrap shell', (tester) async {
    await tester.pumpWidget(const GeoGuideApp());

    expect(find.text('GeoGuide AI'), findsOneWidget);
    expect(find.text('Mobile Bootstrap'), findsOneWidget);
    expect(find.text('P6.1 — Flutter Bootstrap'), findsOneWidget);
  });
}
