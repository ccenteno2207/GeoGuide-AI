import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/tracking/application/route_session_client.dart';
import 'package:geoguide_ai/features/discovery/domain/route_snapshot.dart';
import 'package:geoguide_ai/features/discovery/application/offline_discovery.dart';
import 'package:geoguide_ai/features/discovery/infrastructure/offline/snapshot_codec.dart';
import 'package:geoguide_ai/features/location/domain/location_repository.dart';

import '../discovery/offline_cache_test.dart' as fixtures;
import '../discovery/offline_ui_test.dart' as stores;
import '../location/gps_camera_widget_test.dart' as gps;

class FakeSession implements RouteSessionClient {
  @override
  bool active = false;
  @override
  bool voiceEnabled = false;
  @override
  Future<void> setVoiceConsent(bool enabled) async {
    voiceEnabled = enabled;
  }

  @override
  void Function(LocationSample)? onSample;
  @override
  void Function(RouteSessionStatus)? onState;
  bool denied = false;
  Completer<void>? permissionGate;
  int starts = 0, permissions = 0;
  void Function()? beforeStart;
  @override
  Future<void> refresh() async {}
  @override
  Future<void> requestPermissions() async {
    permissions++;
    await permissionGate?.future;
    if (denied) throw PlatformException(code: 'DENIED');
  }

  @override
  Future<void> start(RouteSnapshot snapshot) async {
    beforeStart?.call();
    starts++;
    active = true;
    onState?.call(RouteSessionStatus.active);
  }

  @override
  Future<void> stop() async {
    active = false;
    voiceEnabled = false;
    onState?.call(RouteSessionStatus.stopped);
  }
}

class PendingLocation extends gps.StreamRepository {
  final pending = Completer<CurrentLocationResult>();
  @override
  Future<CurrentLocationResult> requestCurrentLocation() => pending.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The real map requests its native cache directory on lifecycle resume.
  // Supply only this platform capability; B1 state/producer assertions remain real.
  final cache = Directory.systemTemp.createTempSync('geoguide-b11-widget-');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async {
          if (call.method == 'getApplicationCacheDirectory') return cache.path;
          throw MissingPluginException();
        },
      );
  testWidgets('route start waits for pending normal location request', (
    tester,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final snapshot = const SnapshotCodec().fromEnvelope(
      fixtures.envelope(),
      fixtures.query(),
      now,
    );
    final offline = OfflineDiscovery(
      source: fixtures.Source(),
      store: stores.MemoryStore()..value = snapshot,
      backendContext: snapshot.query.backendContext,
      now: () => now,
    );
    final source = PendingLocation();
    final session = FakeSession();
    await tester.pumpWidget(
      GeoGuideApp(
        locationRepository: source,
        offlineDiscovery: offline,
        routeSession: session,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Activar seguimiento de ubicación'));
    await tester.pump();
    final button = find.byWidgetPredicate(
      (w) => w is IconButton && w.tooltip == 'Iniciar recorrido GPS',
    );
    expect(tester.widget<IconButton>(button).onPressed, isNull);
    expect(session.starts, 0);
    expect(session.permissions, 0);
    source.pending.complete(
      const CurrentLocationResult.available(
        LocationPoint(latitude: -12, longitude: -77),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(button).onPressed, isNotNull);
    expect(source.controller.hasListener, isTrue);
    session.beforeStart = () => expect(source.controller.hasListener, isFalse);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar recorrido'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
    await tester.pumpAndSettle();
    expect(session.starts, 1);
    expect(source.controller.hasListener, isFalse);
    await tester.pumpWidget(const SizedBox());
    await source.controller.close();
  });
  for (final denied in [false, true]) {
    testWidgets('explicit B1 consent and producer cleanup denied=$denied', (
      tester,
    ) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final snapshot = const SnapshotCodec().fromEnvelope(
        fixtures.envelope(),
        fixtures.query(),
        now,
      );
      final offline = OfflineDiscovery(
        source: fixtures.Source(),
        store: stores.MemoryStore()..value = snapshot,
        backendContext: snapshot.query.backendContext,
        now: () => now,
      );
      final source = gps.StreamRepository();
      final session = FakeSession()..denied = denied;
      if (!denied) session.permissionGate = Completer<void>();
      session.beforeStart = () =>
          expect(source.controller.hasListener, isFalse);
      await tester.pumpWidget(
        GeoGuideApp(
          locationRepository: source,
          offlineDiscovery: offline,
          routeSession: session,
        ),
      );
      await tester.pumpAndSettle();
      expect(session.voiceEnabled, isFalse);
      await tester.tap(find.byTooltip('Activar avisos de voz CEFI'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(session.voiceEnabled, isFalse);
      if (!denied) {
        await tester.tap(find.byTooltip('Activar avisos de voz CEFI'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Activar avisos'));
        await tester.pumpAndSettle();
        expect(session.voiceEnabled, isTrue);
        expect(session.starts, 0);
        expect(session.permissions, 0);
        await tester.tap(find.byTooltip('Desactivar avisos de voz CEFI'));
        await tester.pumpAndSettle();
        expect(session.voiceEnabled, isFalse);
      }
      await tester.tap(find.byTooltip('Activar seguimiento de ubicación'));
      await tester.pumpAndSettle();
      expect(source.controller.hasListener, isTrue);
      await tester.tap(find.byTooltip('Iniciar recorrido GPS'));
      await tester.pumpAndSettle();
      expect(session.starts, 0);
      expect(session.permissions, 0);
      await tester.tap(find.text('Iniciar recorrido'));
      await tester.pumpAndSettle();
      if (!denied) {
        expect(find.text('Recorrido GPS: iniciando'), findsOneWidget);
        expect(session.starts, 0);
        expect(
          tester
              .widget<IconButton>(
                find.byWidgetPredicate(
                  (w) => w is IconButton && w.tooltip == 'Ubicación puntual no disponible durante el recorrido GPS',
                ),
              )
              .onPressed,
          isNull,
        );
        session.permissionGate!.complete();
      }
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
      await tester.pumpAndSettle();
      expect(session.permissions, 1);
      expect(source.controller.hasListener, isFalse);
      expect(session.starts, denied ? 0 : 1);
      if (!denied) {
        expect(find.text('Recorrido GPS: activo'), findsOneWidget);
        for (final tooltip in [
          'Ubicación puntual no disponible durante el recorrido GPS',
          'Seguimiento normal no disponible: el recorrido GPS controla la ubicación',
        ]) {
          expect(
            tester
                .widget<IconButton>(
                  find.byWidgetPredicate(
                    (w) => w is IconButton && w.tooltip == tooltip,
                  ),
                )
                .onPressed,
            isNull,
          );
        }
        expect(source.controller.hasListener, isFalse);
        void emit(DateTime time, double accuracy) => session.onSample!(
          LocationSample(
            position: const LocationPoint(latitude: -12, longitude: -77),
            timestamp: time,
            accuracyMeters: accuracy,
          ),
        );
        emit(DateTime.now(), 100);
        await tester.pump();
        expect(find.text('Precisión de ubicación reducida'), findsOneWidget);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        emit(DateTime.now().subtract(const Duration(hours: 1)), 2);
        await tester.pump();
        expect(find.text('Precisión de ubicación reducida'), findsOneWidget);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        emit(DateTime.now().subtract(const Duration(hours: 1)), 2);
        await tester.pump();
        expect(
          find.text('Ubicación desactualizada; esperando actualización'),
          findsOneWidget,
        );
        emit(DateTime.now(), 2);
        await tester.pump();
        expect(find.text('Seguimiento de ubicación activo'), findsOneWidget);
        expect(find.text('Recorrido GPS: activo'), findsOneWidget);
        await tester.tap(find.byTooltip('Detener recorrido GPS'));
        await tester.pumpAndSettle();
        expect(session.active, isFalse);
        expect(find.text('Recorrido detenido'), findsWidgets);
        expect(
          tester
              .widget<IconButton>(
                find.byWidgetPredicate(
                  (w) =>
                      w is IconButton && w.tooltip == 'Usar ubicación actual',
                ),
              )
              .onPressed,
          isNotNull,
        );
        session.onState?.call(RouteSessionStatus.interrupted);
        await tester.pump();
        expect(
          find.textContaining('Recorrido GPS: interrumpido'),
          findsOneWidget,
        );
      } else {
        expect(find.textContaining('No se pudo iniciar'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await source.controller.close();
    });
  }
}
