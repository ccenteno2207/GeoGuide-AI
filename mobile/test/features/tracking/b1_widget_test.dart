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
  void Function(LocationSample)? onSample;
  @override
  void Function(bool)? onState;
  bool denied = false;
  int starts = 0, permissions = 0;
  void Function()? beforeStart;
  @override
  Future<void> refresh() async {}
  @override
  Future<void> requestPermissions() async {
    permissions++;
    if (denied) throw PlatformException(code: 'DENIED');
  }

  @override
  Future<void> start(RouteSnapshot snapshot) async {
    beforeStart?.call();
    starts++;
    active = true;
    onState?.call(true);
  }

  @override
  Future<void> stop() async {
    active = false;
    onState?.call(false);
  }
}

void main() {
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
      await tester.tap(find.byTooltip('Activar seguimiento de ubicación'));
      await tester.pumpAndSettle();
      expect(source.controller.hasListener, isTrue);
      await tester.tap(find.byTooltip('Iniciar recorrido GPS'));
      await tester.pumpAndSettle();
      expect(session.starts, 0);
      expect(session.permissions, 0);
      await tester.tap(find.text('Iniciar recorrido'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
      await tester.pumpAndSettle();
      expect(session.permissions, 1);
      expect(source.controller.hasListener, isFalse);
      expect(session.starts, denied ? 0 : 1);
      if (!denied) {
        await tester.tap(find.byTooltip('Detener recorrido GPS'));
        await tester.pumpAndSettle();
        expect(session.active, isFalse);
      } else {
        expect(find.textContaining('No se pudo iniciar'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await source.controller.close();
    });
  }
}
