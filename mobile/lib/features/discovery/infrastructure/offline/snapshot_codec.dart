import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../domain/route_snapshot.dart';
import '../../domain/discovery_poi.dart';
import '../../../route_planning/domain/route_point.dart';
import '../../../route_planning/infrastructure/route_plan_response_mapper.dart';
import '../route_discovery_response_mapper.dart';

class SnapshotCodec {
  const SnapshotCodec();
  static String backendContext(Uri base) {
    if (base.scheme != 'https' ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty ||
        base.hasQuery ||
        base.hasFragment) {
      throw const CacheFailure('Configuración no apta para copia offline');
    }
    final path = base.path.replaceAll(RegExp(r'/+$'), '');
    return 'https://${base.host.toLowerCase()}:${base.port}$path/api/v1/routes/discover';
  }

  Map<String, Object> point(RoutePoint p) => {
    'latitude': p.latitude == 0 ? 0.0 : p.latitude,
    'longitude': p.longitude == 0 ? 0.0 : p.longitude,
  };
  Map<String, Object> criteria(DiscoveryQuery q) => {
    'origin': point(q.origin),
    'destination': point(q.destination),
    'categories': q.categories,
    'corridorMeters': q.corridorMeters,
    'limit': q.limit,
  };
  String key(DiscoveryQuery q) => sha256
      .convert(
        utf8.encode(
          jsonEncode({
            'backendContext': q.backendContext,
            'criteria': criteria(q),
          }),
        ),
      )
      .toString();
  Map<String, Object?> envelope(RouteSnapshot s) => {
    'route': {
      'origin': point(s.route.origin),
      'destination': point(s.route.destination),
      'distanceMeters': s.route.distanceMeters,
      'durationSeconds': s.route.durationSeconds,
      'geometry': {
        'type': 'LineString',
        'coordinates': s.route.geometry
            .map((p) => [p.longitude, p.latitude])
            .toList(),
      },
    },
    'results': s.pois
        .map(
          (p) => <String, Object?>{
            'id': p.id,
            'name': p.name,
            'category': p.category,
            'location': point(p.location),
            'distanceToRouteMeters': p.distanceToRouteMeters,
            'routeProgress': p.routeProgress,
            'reasonCodes': p.reasonCodes,
            if (p.description != null) 'description': p.description,
            if (p.sourceLabel != null) 'sourceLabel': p.sourceLabel,
            if (p.sourceUrl != null) 'sourceUrl': p.sourceUrl,
            if (p.attribution != null) 'attribution': p.attribution,
          },
        )
        .toList(),
    'algorithmVersion': s.algorithmVersion,
    'generatedAt': s.generatedAt,
  };
  RouteSnapshot fromEnvelope(
    Map<String, Object?> data,
    DiscoveryQuery q,
    int captured,
  ) {
    void invalid() =>
        throw const CacheFailure('Datos no válidos para copia offline');
    final uri = Uri.tryParse(q.backendContext);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        !q.origin.isValid ||
        !q.destination.isValid ||
        q.corridorMeters < 1000 ||
        q.corridorMeters > 10000 ||
        q.limit < 1 ||
        q.limit > 50 ||
        q.categories.any((s) => s.isEmpty || s.contains('\u0000'))) {
      invalid();
    }
    if (q.categories.any((c) => !discoveryCategoryCodes.contains(c))) invalid();
    final rawRoute = data['route'];
    if (rawRoute is! Map<String, Object?>) invalid();
    final route = const RoutePlanResponseMapper().fromJson(
      rawRoute as Map<String, Object?>,
    );
    if (!DiscoveryQuery.samePoint(route.origin, q.origin) ||
        !DiscoveryQuery.samePoint(route.destination, q.destination) ||
        route.distanceMeters < 0 ||
        route.durationSeconds < 0) {
      invalid();
    }
    final raw = data['results'];
    if (raw is! List) invalid();
    final pois = const RouteDiscoveryResponseMapper().fromJson(data);
    if (pois.length != (raw as List).length || pois.length > q.limit) invalid();
    final ids = <String>{};
    for (final p in pois) {
      if (!discoveryCategoryCodes.contains(p.category)) invalid();
      if (!RegExp(
            r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
          ).hasMatch(p.id) ||
          !ids.add(p.id) ||
          p.name.trim().isEmpty ||
          p.category.trim().isEmpty) {
        invalid();
      }
    }
    for (final p in raw) {
      for (final field in [
        'description',
        'sourceLabel',
        'sourceUrl',
        'attribution',
      ]) {
        if ((p as Map)[field] != null && p[field] is! String) invalid();
      }
    }
    final algorithm = data['algorithmVersion'], generated = data['generatedAt'];
    if (algorithm is! String ||
        algorithm.trim().isEmpty ||
        generated is! String ||
        DateTime.tryParse(generated) == null ||
        captured < 0) {
      invalid();
    }
    return RouteSnapshot(
      query: q,
      route: route,
      pois: pois,
      algorithmVersion: algorithm as String,
      generatedAt: generated as String,
      capturedAtUtcMs: captured,
    );
  }

  Uint8List encode(RouteSnapshot s) {
    final e = envelope(s);
    fromEnvelope(e, s.query, s.capturedAtUtcMs);
    final bytes = Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'formatVersion': 1,
          'capturedAtUtcMs': s.capturedAtUtcMs,
          'expiresAtUtcMs': s.expiresAtUtcMs,
          'backendContext': s.query.backendContext,
          'criteria': criteria(s.query),
          'queryKeySha256': key(s.query),
          'route': e['route'],
          'pois': e['results'],
          'algorithmVersion': s.algorithmVersion,
          'generatedAt': s.generatedAt,
        }),
      ),
    );
    if (bytes.length > RouteSnapshot.maxPayloadBytes) {
      throw const CacheFailure(
        'La copia supera 5 MiB; se conserva la anterior',
      );
    }
    return bytes;
  }

  RouteSnapshot decode(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > RouteSnapshot.maxPayloadBytes) {
      throw const FormatException('size');
    }
    final j = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    if (j['formatVersion'] != 1 ||
        j['capturedAtUtcMs'] is! int ||
        j['expiresAtUtcMs'] != j['capturedAtUtcMs'] + RouteSnapshot.ttlMs) {
      throw const FormatException('format');
    }
    final c = j['criteria'] as Map;
    RoutePoint p(dynamic x) => RoutePoint(
      latitude: (x['latitude'] as num).toDouble(),
      longitude: (x['longitude'] as num).toDouble(),
    );
    final q = DiscoveryQuery(
      backendContext: j['backendContext'] as String,
      origin: p(c['origin']),
      destination: p(c['destination']),
      categories: (c['categories'] as List).cast<String>().toSet(),
      corridorMeters: c['corridorMeters'] as int,
      limit: c['limit'] as int,
    );
    if (j['queryKeySha256'] != key(q)) throw const FormatException('query');
    final s = fromEnvelope(
      {
        'route': j['route'],
        'results': j['pois'],
        'algorithmVersion': j['algorithmVersion'],
        'generatedAt': j['generatedAt'],
      },
      q,
      j['capturedAtUtcMs'] as int,
    );
    // Reject extra fields and noncanonical encodings, never rescue part of a payload.
    if (base64Encode(encode(s)) != base64Encode(bytes)) {
      throw const FormatException('canonical');
    }
    return s;
  }
}
