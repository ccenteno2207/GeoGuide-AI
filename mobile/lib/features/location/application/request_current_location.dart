import '../domain/location_repository.dart';

class RequestCurrentLocation {
  const RequestCurrentLocation(this._repository);

  final LocationRepository _repository;

  Future<CurrentLocationResult> call({bool requestPermission = true}) =>
      _repository.requestCurrentLocation(requestPermission: requestPermission);

  Stream<LocationSample> watch() => _repository is LocationStreamSource
      ? (_repository as LocationStreamSource).watchLocation()
      : const Stream<LocationSample>.empty();
}
