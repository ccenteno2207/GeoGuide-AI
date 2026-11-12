import '../domain/destination_search_repository.dart';
import '../domain/destination_search_result.dart';

class SearchDestinations {
  const SearchDestinations(this._repository);

  final DestinationSearchRepository _repository;

  Future<List<DestinationSearchResult>> call(String query) {
    final normalizedQuery = query.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalizedQuery.isEmpty) return Future.value(const []);
    return _repository.searchByName(normalizedQuery);
  }
}
