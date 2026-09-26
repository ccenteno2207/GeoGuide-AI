import '../../../core/network/app_failure.dart';
import '../../../core/network/geoguide_http_client.dart';
import '../domain/planned_route.dart';
import '../domain/route_planning_repository.dart';
import '../domain/route_point.dart';
import 'route_plan_response_mapper.dart';

class DioRoutePlanningRepository implements RoutePlanningRepository {
  DioRoutePlanningRepository(
    this._client, {
    this._mapper = const RoutePlanResponseMapper(),
  });

  final GeoGuideHttpClient _client;
  final RoutePlanResponseMapper _mapper;

  @override
  Future<PlannedRoute> planRoute({
    required RoutePoint origin,
    required RoutePoint destination,
  }) async {
    if (!origin.isValid || !destination.isValid) {
      throw const AppFailure(AppFailureType.validation);
    }

    final json = await _client.postJson(
      path: '/api/v1/routes/plan',
      body: {
        'origin': origin.toRequestJson(),
        'destination': destination.toRequestJson(),
      },
    );
    return _mapper.fromJson(json);
  }
}
