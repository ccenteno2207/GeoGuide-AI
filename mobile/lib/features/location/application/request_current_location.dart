import '../domain/location_repository.dart';

class RequestCurrentLocation {
  const RequestCurrentLocation(this._repository);

  final LocationRepository _repository;

  Future<CurrentLocationResult> call() => _repository.requestCurrentLocation();
}
