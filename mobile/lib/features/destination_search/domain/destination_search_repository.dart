import 'destination_search_result.dart';

/// Port for an explicitly submitted destination-name query.
///
/// No production adapter is provided until a destination source and its API
/// contract are approved.
abstract interface class DestinationSearchRepository {
  Future<List<DestinationSearchResult>> searchByName(String query);
}
