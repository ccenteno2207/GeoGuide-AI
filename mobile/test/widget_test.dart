import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geoguide_ai/app/app.dart';

void main() {
  testWidgets('renders the GeoGuide AI base map shell', (tester) async {
    await tester.pumpWidget(const GeoGuideApp());

    expect(find.text('GeoGuide AI'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('OpenStreetMap contributors'), findsOneWidget);
  });
}
