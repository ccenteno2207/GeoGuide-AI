import '../../../core/network/geoguide_http_client.dart';
import '../domain/poi_operational_info.dart';

class DioPoiOperationalInfoRepository {
  const DioPoiOperationalInfoRepository(this._client);
  final GeoGuideHttpClient _client;

  Future<PoiOperationalInfo> getForPoi(String poiId) async {
    final json = await _client.getJson(
      path: '/api/v1/pois/$poiId/operational-info',
    );
    return PoiOperationalInfo.fromJson(json);
  }
}
