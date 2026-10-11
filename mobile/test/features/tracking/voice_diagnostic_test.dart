import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/tracking/presentation/voice_diagnostic.dart';

class FakeDiagnostic implements VoiceDiagnosticPort {
  final completion = Completer<String>();
  int starts = 0, stops = 0;
  @override
  Future<String> start() {
    starts++;
    return completion.future;
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}

void main() {
  test('debug and Driving exclusion', () {
    expect(VoiceDiagnosticAction.available(debug: true, driving: false), true);
    expect(
      VoiceDiagnosticAction.available(debug: false, driving: false),
      false,
    );
    expect(VoiceDiagnosticAction.available(debug: true, driving: true), false);
  });
  Future<void> show(
    WidgetTester t,
    FakeDiagnostic p, {
    bool consent = true,
    bool route = false,
  }) => t.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VoiceDiagnosticDialog(
          consent: consent,
          routeBusy: route,
          port: p,
        ),
      ),
    ),
  );
  for (final scenario in ['consent', 'route']) {
    testWidgets('rejects $scenario without starting output', (t) async {
      final p = FakeDiagnostic();
      await show(
        t,
        p,
        consent: scenario != 'consent',
        route: scenario == 'route',
      );
      expect(
        t.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(p.starts, 0);
    });
  }
  for (final entry in {
    'COMPLETED': 'Completado',
    'CANCELLED': 'Cancelado',
    'FOCUS_DENIED': 'Foco de audio denegado',
    'NO_SPANISH_VOICE': 'Voz española local no disponible',
    'ERROR': 'Error de voz o limpieza',
  }.entries) {
    testWidgets('single flight and ${entry.key}', (t) async {
      final p = FakeDiagnostic();
      await show(t, p);
      await t.tap(find.widgetWithText(FilledButton, 'Probar voz CEFI'));
      await t.pump();
      expect(p.starts, 1);
      expect(find.byType(FilledButton), findsNothing);
      if (entry.key == 'CANCELLED') {
        await t.tap(find.text('Detener prueba'));
        await t.pump();
        expect(p.stops, 1);
        expect(find.byType(FilledButton), findsNothing);
      }
      p.completion.complete(entry.key);
      await t.pump();
      expect(find.text(entry.value), findsOneWidget);
    });
  }
  testWidgets('dispose cancels and ignores late ack', (t) async {
    final p = FakeDiagnostic();
    await show(t, p);
    await t.tap(find.widgetWithText(FilledButton, 'Probar voz CEFI'));
    await t.pump();
    await t.pumpWidget(const SizedBox());
    expect(p.stops, 1);
    p.completion.complete('COMPLETED');
    await t.pump();
    expect(t.takeException(), isNull);
  });
}
