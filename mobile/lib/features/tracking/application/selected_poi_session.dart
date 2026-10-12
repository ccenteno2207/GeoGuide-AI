import '../../discovery/domain/route_snapshot.dart';

/// Ephemeral draft; object identity intentionally distinguishes equal queries.
class SelectedPoiDraft {
  RouteSnapshot? _snapshot;
  final Set<String> _ids = {};
  bool _frozen = false;
  Set<String> get ids => Set.unmodifiable(_ids);
  bool get frozen => _frozen;
  void bind(RouteSnapshot? snapshot, int now) {
    if (_frozen) return;
    if (!identical(snapshot, _snapshot) || snapshot?.eligible(now) != true) {
      _ids.clear();
      _snapshot = snapshot?.eligible(now) == true ? snapshot : null;
    }
  }

  void toggle(String id, int now) {
    if (_frozen ||
        _snapshot?.eligible(now) != true ||
        !_snapshot!.pois.any((p) => p.id == id)) {
      throw StateError('Selection unavailable');
    }
    if (!_ids.remove(id)) _ids.add(id);
  }

  SelectedPoiSession freeze(RouteSnapshot snapshot, int now) {
    bind(snapshot, now);
    if (_frozen || !identical(snapshot, _snapshot)) {
      throw StateError('Selection unavailable');
    }
    final result = SelectedPoiSession(snapshot, _ids, now);
    _frozen = true;
    return result;
  }

  void clear() {
    _snapshot = null;
    _ids.clear();
    _frozen = false;
  }
}

class SelectedPoiSession {
  SelectedPoiSession(this.snapshot, Iterable<String> chosen, int now)
    : chosenIds = Set.unmodifiable(chosen) {
    final values = chosen.toList();
    if (!snapshot.eligible(now) ||
        values.length != chosenIds.length ||
        values.any((id) => !snapshot.pois.any((p) => p.id == id))) {
      throw ArgumentError('Invalid session selection');
    }
  }
  final RouteSnapshot snapshot;
  final Set<String> chosenIds;
}
