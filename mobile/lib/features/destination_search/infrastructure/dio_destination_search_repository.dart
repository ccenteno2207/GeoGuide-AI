import '../../../core/network/geoguide_http_client.dart';
import '../../route_planning/domain/route_point.dart';
import '../domain/destination_search_repository.dart';
import '../domain/destination_search_result.dart';

class DioDestinationSearchRepository implements DestinationSearchRepository {
  const DioDestinationSearchRepository(this._client);

  final GeoGuideHttpClient _client;

  @override
  Future<List<DestinationSearchResult>> searchByName(String query) async {
    final response = await _client.postJson(
      path: '/api/v1/destinations/search',
      body: {'query': query, 'limit': 10},
    );
    final rawResults = response['results'];
    if (rawResults is! List) {
      throw const FormatException('Destination search response is invalid');
    }
    return rawResults
        .map((raw) {
          if (raw is! Map) {
            throw const FormatException('Destination result is invalid');
          }
          final item = raw.map((key, value) => MapEntry(key.toString(), value));
          final latitude = (item['latitude'] as num?)?.toDouble();
          final longitude = (item['longitude'] as num?)?.toDouble();
          final point = latitude == null || longitude == null
              ? null
              : RoutePoint(latitude: latitude, longitude: longitude);
          return DestinationSearchResult(
            id: item['id']?.toString() ?? '',
            name: item['name']?.toString() ?? '',
            typeLabel: item['type']?.toString() ?? '',
            geographicContext: item['administrativeContext']?.toString() ?? '',
            provenanceLabel: item['source']?.toString() ?? '',
            sourceUrl: item['sourceUrl']?.toString() ?? '',
            license: item['license']?.toString() ?? '',
            attribution: item['attribution']?.toString() ?? '',
            verifiedPoint: point?.isValid == true ? point : null,
          );
        })
        .toList(growable: false);
  }
}
