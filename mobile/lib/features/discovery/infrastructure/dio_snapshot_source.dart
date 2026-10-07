import '../../../core/network/app_failure.dart';
import '../../../core/network/geoguide_http_client.dart';
import '../domain/route_snapshot.dart';
import 'offline/snapshot_codec.dart';

class DioSnapshotSource implements DiscoverySnapshotSource {
  DioSnapshotSource(this.client, {int Function()? now})
    : now = now ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);
  final GeoGuideHttpClient client;
  final int Function() now;
  @override
  Future<RouteSnapshot> discover(DiscoveryQuery query) async {
    final json = await client.postJson(
      path: '/api/v1/routes/discover',
      body: {
        'origin': query.origin.toRequestJson(),
        'destination': query.destination.toRequestJson(),
        'categories': query.categories,
        'corridorMeters': query.corridorMeters,
        'limit': query.limit,
      },
    );
    try {
      return const SnapshotCodec().fromEnvelope(json, query, now());
    } catch (_) {
      throw const AppFailure(AppFailureType.invalidResponse);
    }
  }
}
