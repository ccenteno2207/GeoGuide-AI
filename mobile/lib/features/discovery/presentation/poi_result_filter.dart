import '../domain/discovery_poi.dart';
import '../domain/route_snapshot.dart';
import 'unicode_name_normalization.dart';

/// Ephemeral exploration state. Never changes the snapshot, query or ranking.
class PoiResultFilter {
  RouteSnapshot? _snapshot;
  String query = '';

  bool bind(RouteSnapshot? snapshot, int now) {
    final current = snapshot?.eligible(now) == true ? snapshot : null;
    final changed = !identical(current, _snapshot);
    if (changed) query = '';
    _snapshot = current;
    return changed;
  }

  void clear() => query = '';

  List<DiscoveryPoi> visible(int now) {
    final snapshot = _snapshot;
    if (snapshot == null || !snapshot.eligible(now)) return const [];
    final needle = normalizePoiName(query);
    if (needle.isEmpty) return snapshot.pois;
    return snapshot.pois
        .where((poi) => normalizePoiName(poi.name).contains(needle))
        .toList(growable: false);
  }
}
