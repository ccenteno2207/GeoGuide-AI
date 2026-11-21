import '../../../core/network/geoguide_http_client.dart';
import '../domain/poi_tourism_content.dart';

class DioPoiTourismContentRepository {
  const DioPoiTourismContentRepository(this._client);
  final GeoGuideHttpClient _client;

  Future<PoiTourismContent> getForPoi(String poiId) async {
    final json = await _client.getJson(path: '/api/v1/pois/$poiId/content');
    final mapped = Map<String, Object?>.from(json);
    final photos = mapped['photos'];
    if (photos is List) {
      mapped['photos'] = photos
          .map((photo) {
            if (photo is! Map) {
              return photo;
            }
            final item = Map<String, Object?>.from(photo);
            final path = item['path'];
            if (path is String) {
              item['path'] = _client.resolveApiPath(path).toString();
            }
            return item;
          })
          .toList(growable: false);
    }
    return PoiTourismContent.fromJson(mapped);
  }
}
