import '../../discovery/domain/route_snapshot.dart';
import '../../location/domain/location_repository.dart';

enum RouteSessionStatus { stopped, starting, active, interrupted }

abstract interface class RouteSessionClient {
  bool get active;
  bool get voiceEnabled;
  Future<void> setVoiceConsent(bool enabled);
  set onSample(void Function(LocationSample)? value);
  set onState(void Function(RouteSessionStatus)? value);
  Future<void> requestPermissions();
  Future<void> start(RouteSnapshot snapshot);
  Future<void> stop();
  Future<void> refresh();
}
