import 'package:drift/drift.dart';
part 'snapshot_database.g.dart';

class RouteDiscoverySnapshot extends Table {
  IntColumn get slot =>
      integer().customConstraint('NOT NULL CHECK (slot = 1)')();
  IntColumn get formatVersion => integer()();
  BlobColumn get payload => blob()();
  IntColumn get payloadBytes => integer()();
  BlobColumn get payloadSha256 => blob()();
  IntColumn get capturedAtUtcMs => integer()();
  IntColumn get expiresAtUtcMs => integer()();
  IntColumn get lastObservedUtcMs => integer()();
  @override
  Set<Column> get primaryKey => {slot};
}

@DriftDatabase(tables: [RouteDiscoverySnapshot])
class SnapshotDatabase extends _$SnapshotDatabase {
  SnapshotDatabase(super.executor);
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async =>
        throw StateError('Incompatible local schema'),
  );
}
