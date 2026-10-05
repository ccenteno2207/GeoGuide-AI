import '../../../core/network/app_failure.dart';
import '../../../core/network/geoguide_http_client.dart';
import '../../route_planning/domain/route_point.dart';
import '../domain/discovery_poi.dart';
import '../domain/route_discovery_repository.dart';
import 'route_discovery_response_mapper.dart';

class DioRouteDiscoveryRepository implements RouteDiscoveryRepository {
  DioRouteDiscoveryRepository(
    this._client, {
    this._mapper = const RouteDiscoveryResponseMapper(),
  });

  final GeoGuideHttpClient _client;
  final RouteDiscoveryResponseMapper _mapper;

  @override
  Future<List<DiscoveryPoi>> discover({
    required RoutePoint origin,
    required RoutePoint destination,
    Set<String> categories = const {},
  }) async {
    if (!origin.isValid || !destination.isValid) {
      throw const AppFailure(AppFailureType.validation);
    }

    final json = await _client.postJson(
      path: '/api/v1/routes/discover',
      body: {
        'origin': origin.toRequestJson(),
        'destination': destination.toRequestJson(),
        'categories': categories.toList(growable: false),
      },
    );
    return _mapper.fromJson(json);
  }
}
