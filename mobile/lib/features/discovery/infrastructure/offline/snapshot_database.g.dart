// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_database.dart';

// ignore_for_file: type=lint
class $RouteDiscoverySnapshotTable extends RouteDiscoverySnapshot
    with TableInfo<$RouteDiscoverySnapshotTable, RouteDiscoverySnapshotData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RouteDiscoverySnapshotTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL CHECK (slot = 1)',
  );
  static const VerificationMeta _formatVersionMeta = const VerificationMeta(
    'formatVersion',
  );
  @override
  late final GeneratedColumn<int> formatVersion = GeneratedColumn<int>(
    'format_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<Uint8List> payload = GeneratedColumn<Uint8List>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadBytesMeta = const VerificationMeta(
    'payloadBytes',
  );
  @override
  late final GeneratedColumn<int> payloadBytes = GeneratedColumn<int>(
    'payload_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadSha256Meta = const VerificationMeta(
    'payloadSha256',
  );
  @override
  late final GeneratedColumn<Uint8List> payloadSha256 =
      GeneratedColumn<Uint8List>(
        'payload_sha256',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _capturedAtUtcMsMeta = const VerificationMeta(
    'capturedAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> capturedAtUtcMs = GeneratedColumn<int>(
    'captured_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtUtcMsMeta = const VerificationMeta(
    'expiresAtUtcMs',
  );
  @override
  late final GeneratedColumn<int> expiresAtUtcMs = GeneratedColumn<int>(
    'expires_at_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastObservedUtcMsMeta = const VerificationMeta(
    'lastObservedUtcMs',
  );
  @override
  late final GeneratedColumn<int> lastObservedUtcMs = GeneratedColumn<int>(
    'last_observed_utc_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    slot,
    formatVersion,
    payload,
    payloadBytes,
    payloadSha256,
    capturedAtUtcMs,
    expiresAtUtcMs,
    lastObservedUtcMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_discovery_snapshot';
  @override
  VerificationContext validateIntegrity(
    Insertable<RouteDiscoverySnapshotData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    }
    if (data.containsKey('format_version')) {
      context.handle(
        _formatVersionMeta,
        formatVersion.isAcceptableOrUnknown(
          data['format_version']!,
          _formatVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_formatVersionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('payload_bytes')) {
      context.handle(
        _payloadBytesMeta,
        payloadBytes.isAcceptableOrUnknown(
          data['payload_bytes']!,
          _payloadBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadBytesMeta);
    }
    if (data.containsKey('payload_sha256')) {
      context.handle(
        _payloadSha256Meta,
        payloadSha256.isAcceptableOrUnknown(
          data['payload_sha256']!,
          _payloadSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadSha256Meta);
    }
    if (data.containsKey('captured_at_utc_ms')) {
      context.handle(
        _capturedAtUtcMsMeta,
        capturedAtUtcMs.isAcceptableOrUnknown(
          data['captured_at_utc_ms']!,
          _capturedAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capturedAtUtcMsMeta);
    }
    if (data.containsKey('expires_at_utc_ms')) {
      context.handle(
        _expiresAtUtcMsMeta,
        expiresAtUtcMs.isAcceptableOrUnknown(
          data['expires_at_utc_ms']!,
          _expiresAtUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expiresAtUtcMsMeta);
    }
    if (data.containsKey('last_observed_utc_ms')) {
      context.handle(
        _lastObservedUtcMsMeta,
        lastObservedUtcMs.isAcceptableOrUnknown(
          data['last_observed_utc_ms']!,
          _lastObservedUtcMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastObservedUtcMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  RouteDiscoverySnapshotData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteDiscoverySnapshotData(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      formatVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}format_version'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload'],
      )!,
      payloadBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_bytes'],
      )!,
      payloadSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload_sha256'],
      )!,
      capturedAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}captured_at_utc_ms'],
      )!,
      expiresAtUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at_utc_ms'],
      )!,
      lastObservedUtcMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_observed_utc_ms'],
      )!,
    );
  }

  @override
  $RouteDiscoverySnapshotTable createAlias(String alias) {
    return $RouteDiscoverySnapshotTable(attachedDatabase, alias);
  }
}

class RouteDiscoverySnapshotData extends DataClass
    implements Insertable<RouteDiscoverySnapshotData> {
  final int slot;
  final int formatVersion;
  final Uint8List payload;
  final int payloadBytes;
  final Uint8List payloadSha256;
  final int capturedAtUtcMs;
  final int expiresAtUtcMs;
  final int lastObservedUtcMs;
  const RouteDiscoverySnapshotData({
    required this.slot,
    required this.formatVersion,
    required this.payload,
    required this.payloadBytes,
    required this.payloadSha256,
    required this.capturedAtUtcMs,
    required this.expiresAtUtcMs,
    required this.lastObservedUtcMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<int>(slot);
    map['format_version'] = Variable<int>(formatVersion);
    map['payload'] = Variable<Uint8List>(payload);
    map['payload_bytes'] = Variable<int>(payloadBytes);
    map['payload_sha256'] = Variable<Uint8List>(payloadSha256);
    map['captured_at_utc_ms'] = Variable<int>(capturedAtUtcMs);
    map['expires_at_utc_ms'] = Variable<int>(expiresAtUtcMs);
    map['last_observed_utc_ms'] = Variable<int>(lastObservedUtcMs);
    return map;
  }

  RouteDiscoverySnapshotCompanion toCompanion(bool nullToAbsent) {
    return RouteDiscoverySnapshotCompanion(
      slot: Value(slot),
      formatVersion: Value(formatVersion),
      payload: Value(payload),
      payloadBytes: Value(payloadBytes),
      payloadSha256: Value(payloadSha256),
      capturedAtUtcMs: Value(capturedAtUtcMs),
      expiresAtUtcMs: Value(expiresAtUtcMs),
      lastObservedUtcMs: Value(lastObservedUtcMs),
    );
  }

  factory RouteDiscoverySnapshotData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouteDiscoverySnapshotData(
      slot: serializer.fromJson<int>(json['slot']),
      formatVersion: serializer.fromJson<int>(json['formatVersion']),
      payload: serializer.fromJson<Uint8List>(json['payload']),
      payloadBytes: serializer.fromJson<int>(json['payloadBytes']),
      payloadSha256: serializer.fromJson<Uint8List>(json['payloadSha256']),
      capturedAtUtcMs: serializer.fromJson<int>(json['capturedAtUtcMs']),
      expiresAtUtcMs: serializer.fromJson<int>(json['expiresAtUtcMs']),
      lastObservedUtcMs: serializer.fromJson<int>(json['lastObservedUtcMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<int>(slot),
      'formatVersion': serializer.toJson<int>(formatVersion),
      'payload': serializer.toJson<Uint8List>(payload),
      'payloadBytes': serializer.toJson<int>(payloadBytes),
      'payloadSha256': serializer.toJson<Uint8List>(payloadSha256),
      'capturedAtUtcMs': serializer.toJson<int>(capturedAtUtcMs),
      'expiresAtUtcMs': serializer.toJson<int>(expiresAtUtcMs),
      'lastObservedUtcMs': serializer.toJson<int>(lastObservedUtcMs),
    };
  }

  RouteDiscoverySnapshotData copyWith({
    int? slot,
    int? formatVersion,
    Uint8List? payload,
    int? payloadBytes,
    Uint8List? payloadSha256,
    int? capturedAtUtcMs,
    int? expiresAtUtcMs,
    int? lastObservedUtcMs,
  }) => RouteDiscoverySnapshotData(
    slot: slot ?? this.slot,
    formatVersion: formatVersion ?? this.formatVersion,
    payload: payload ?? this.payload,
    payloadBytes: payloadBytes ?? this.payloadBytes,
    payloadSha256: payloadSha256 ?? this.payloadSha256,
    capturedAtUtcMs: capturedAtUtcMs ?? this.capturedAtUtcMs,
    expiresAtUtcMs: expiresAtUtcMs ?? this.expiresAtUtcMs,
    lastObservedUtcMs: lastObservedUtcMs ?? this.lastObservedUtcMs,
  );
  RouteDiscoverySnapshotData copyWithCompanion(
    RouteDiscoverySnapshotCompanion data,
  ) {
    return RouteDiscoverySnapshotData(
      slot: data.slot.present ? data.slot.value : this.slot,
      formatVersion: data.formatVersion.present
          ? data.formatVersion.value
          : this.formatVersion,
      payload: data.payload.present ? data.payload.value : this.payload,
      payloadBytes: data.payloadBytes.present
          ? data.payloadBytes.value
          : this.payloadBytes,
      payloadSha256: data.payloadSha256.present
          ? data.payloadSha256.value
          : this.payloadSha256,
      capturedAtUtcMs: data.capturedAtUtcMs.present
          ? data.capturedAtUtcMs.value
          : this.capturedAtUtcMs,
      expiresAtUtcMs: data.expiresAtUtcMs.present
          ? data.expiresAtUtcMs.value
          : this.expiresAtUtcMs,
      lastObservedUtcMs: data.lastObservedUtcMs.present
          ? data.lastObservedUtcMs.value
          : this.lastObservedUtcMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouteDiscoverySnapshotData(')
          ..write('slot: $slot, ')
          ..write('formatVersion: $formatVersion, ')
          ..write('payload: $payload, ')
          ..write('payloadBytes: $payloadBytes, ')
          ..write('payloadSha256: $payloadSha256, ')
          ..write('capturedAtUtcMs: $capturedAtUtcMs, ')
          ..write('expiresAtUtcMs: $expiresAtUtcMs, ')
          ..write('lastObservedUtcMs: $lastObservedUtcMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    slot,
    formatVersion,
    $driftBlobEquality.hash(payload),
    payloadBytes,
    $driftBlobEquality.hash(payloadSha256),
    capturedAtUtcMs,
    expiresAtUtcMs,
    lastObservedUtcMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteDiscoverySnapshotData &&
          other.slot == this.slot &&
          other.formatVersion == this.formatVersion &&
          $driftBlobEquality.equals(other.payload, this.payload) &&
          other.payloadBytes == this.payloadBytes &&
          $driftBlobEquality.equals(other.payloadSha256, this.payloadSha256) &&
          other.capturedAtUtcMs == this.capturedAtUtcMs &&
          other.expiresAtUtcMs == this.expiresAtUtcMs &&
          other.lastObservedUtcMs == this.lastObservedUtcMs);
}

class RouteDiscoverySnapshotCompanion
    extends UpdateCompanion<RouteDiscoverySnapshotData> {
  final Value<int> slot;
  final Value<int> formatVersion;
  final Value<Uint8List> payload;
  final Value<int> payloadBytes;
  final Value<Uint8List> payloadSha256;
  final Value<int> capturedAtUtcMs;
  final Value<int> expiresAtUtcMs;
  final Value<int> lastObservedUtcMs;
  const RouteDiscoverySnapshotCompanion({
    this.slot = const Value.absent(),
    this.formatVersion = const Value.absent(),
    this.payload = const Value.absent(),
    this.payloadBytes = const Value.absent(),
    this.payloadSha256 = const Value.absent(),
    this.capturedAtUtcMs = const Value.absent(),
    this.expiresAtUtcMs = const Value.absent(),
    this.lastObservedUtcMs = const Value.absent(),
  });
  RouteDiscoverySnapshotCompanion.insert({
    this.slot = const Value.absent(),
    required int formatVersion,
    required Uint8List payload,
    required int payloadBytes,
    required Uint8List payloadSha256,
    required int capturedAtUtcMs,
    required int expiresAtUtcMs,
    required int lastObservedUtcMs,
  }) : formatVersion = Value(formatVersion),
       payload = Value(payload),
       payloadBytes = Value(payloadBytes),
       payloadSha256 = Value(payloadSha256),
       capturedAtUtcMs = Value(capturedAtUtcMs),
       expiresAtUtcMs = Value(expiresAtUtcMs),
       lastObservedUtcMs = Value(lastObservedUtcMs);
  static Insertable<RouteDiscoverySnapshotData> custom({
    Expression<int>? slot,
    Expression<int>? formatVersion,
    Expression<Uint8List>? payload,
    Expression<int>? payloadBytes,
    Expression<Uint8List>? payloadSha256,
    Expression<int>? capturedAtUtcMs,
    Expression<int>? expiresAtUtcMs,
    Expression<int>? lastObservedUtcMs,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (formatVersion != null) 'format_version': formatVersion,
      if (payload != null) 'payload': payload,
      if (payloadBytes != null) 'payload_bytes': payloadBytes,
      if (payloadSha256 != null) 'payload_sha256': payloadSha256,
      if (capturedAtUtcMs != null) 'captured_at_utc_ms': capturedAtUtcMs,
      if (expiresAtUtcMs != null) 'expires_at_utc_ms': expiresAtUtcMs,
      if (lastObservedUtcMs != null) 'last_observed_utc_ms': lastObservedUtcMs,
    });
  }

  RouteDiscoverySnapshotCompanion copyWith({
    Value<int>? slot,
    Value<int>? formatVersion,
    Value<Uint8List>? payload,
    Value<int>? payloadBytes,
    Value<Uint8List>? payloadSha256,
    Value<int>? capturedAtUtcMs,
    Value<int>? expiresAtUtcMs,
    Value<int>? lastObservedUtcMs,
  }) {
    return RouteDiscoverySnapshotCompanion(
      slot: slot ?? this.slot,
      formatVersion: formatVersion ?? this.formatVersion,
      payload: payload ?? this.payload,
      payloadBytes: payloadBytes ?? this.payloadBytes,
      payloadSha256: payloadSha256 ?? this.payloadSha256,
      capturedAtUtcMs: capturedAtUtcMs ?? this.capturedAtUtcMs,
      expiresAtUtcMs: expiresAtUtcMs ?? this.expiresAtUtcMs,
      lastObservedUtcMs: lastObservedUtcMs ?? this.lastObservedUtcMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (formatVersion.present) {
      map['format_version'] = Variable<int>(formatVersion.value);
    }
    if (payload.present) {
      map['payload'] = Variable<Uint8List>(payload.value);
    }
    if (payloadBytes.present) {
      map['payload_bytes'] = Variable<int>(payloadBytes.value);
    }
    if (payloadSha256.present) {
      map['payload_sha256'] = Variable<Uint8List>(payloadSha256.value);
    }
    if (capturedAtUtcMs.present) {
      map['captured_at_utc_ms'] = Variable<int>(capturedAtUtcMs.value);
    }
    if (expiresAtUtcMs.present) {
      map['expires_at_utc_ms'] = Variable<int>(expiresAtUtcMs.value);
    }
    if (lastObservedUtcMs.present) {
      map['last_observed_utc_ms'] = Variable<int>(lastObservedUtcMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RouteDiscoverySnapshotCompanion(')
          ..write('slot: $slot, ')
          ..write('formatVersion: $formatVersion, ')
          ..write('payload: $payload, ')
          ..write('payloadBytes: $payloadBytes, ')
          ..write('payloadSha256: $payloadSha256, ')
          ..write('capturedAtUtcMs: $capturedAtUtcMs, ')
          ..write('expiresAtUtcMs: $expiresAtUtcMs, ')
          ..write('lastObservedUtcMs: $lastObservedUtcMs')
          ..write(')'))
        .toString();
  }
}

abstract class _$SnapshotDatabase extends GeneratedDatabase {
  _$SnapshotDatabase(QueryExecutor e) : super(e);
  $SnapshotDatabaseManager get managers => $SnapshotDatabaseManager(this);
  late final $RouteDiscoverySnapshotTable routeDiscoverySnapshot =
      $RouteDiscoverySnapshotTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [routeDiscoverySnapshot];
}

typedef $$RouteDiscoverySnapshotTableCreateCompanionBuilder =
    RouteDiscoverySnapshotCompanion Function({
      Value<int> slot,
      required int formatVersion,
      required Uint8List payload,
      required int payloadBytes,
      required Uint8List payloadSha256,
      required int capturedAtUtcMs,
      required int expiresAtUtcMs,
      required int lastObservedUtcMs,
    });
typedef $$RouteDiscoverySnapshotTableUpdateCompanionBuilder =
    RouteDiscoverySnapshotCompanion Function({
      Value<int> slot,
      Value<int> formatVersion,
      Value<Uint8List> payload,
      Value<int> payloadBytes,
      Value<Uint8List> payloadSha256,
      Value<int> capturedAtUtcMs,
      Value<int> expiresAtUtcMs,
      Value<int> lastObservedUtcMs,
    });

class $$RouteDiscoverySnapshotTableFilterComposer
    extends Composer<_$SnapshotDatabase, $RouteDiscoverySnapshotTable> {
  $$RouteDiscoverySnapshotTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadBytes => $composableBuilder(
    column: $table.payloadBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payloadSha256 => $composableBuilder(
    column: $table.payloadSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capturedAtUtcMs => $composableBuilder(
    column: $table.capturedAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAtUtcMs => $composableBuilder(
    column: $table.expiresAtUtcMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastObservedUtcMs => $composableBuilder(
    column: $table.lastObservedUtcMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RouteDiscoverySnapshotTableOrderingComposer
    extends Composer<_$SnapshotDatabase, $RouteDiscoverySnapshotTable> {
  $$RouteDiscoverySnapshotTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadBytes => $composableBuilder(
    column: $table.payloadBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payloadSha256 => $composableBuilder(
    column: $table.payloadSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capturedAtUtcMs => $composableBuilder(
    column: $table.capturedAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAtUtcMs => $composableBuilder(
    column: $table.expiresAtUtcMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastObservedUtcMs => $composableBuilder(
    column: $table.lastObservedUtcMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RouteDiscoverySnapshotTableAnnotationComposer
    extends Composer<_$SnapshotDatabase, $RouteDiscoverySnapshotTable> {
  $$RouteDiscoverySnapshotTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<int> get formatVersion => $composableBuilder(
    column: $table.formatVersion,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get payloadBytes => $composableBuilder(
    column: $table.payloadBytes,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get payloadSha256 => $composableBuilder(
    column: $table.payloadSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capturedAtUtcMs => $composableBuilder(
    column: $table.capturedAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expiresAtUtcMs => $composableBuilder(
    column: $table.expiresAtUtcMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastObservedUtcMs => $composableBuilder(
    column: $table.lastObservedUtcMs,
    builder: (column) => column,
  );
}

class $$RouteDiscoverySnapshotTableTableManager
    extends
        RootTableManager<
          _$SnapshotDatabase,
          $RouteDiscoverySnapshotTable,
          RouteDiscoverySnapshotData,
          $$RouteDiscoverySnapshotTableFilterComposer,
          $$RouteDiscoverySnapshotTableOrderingComposer,
          $$RouteDiscoverySnapshotTableAnnotationComposer,
          $$RouteDiscoverySnapshotTableCreateCompanionBuilder,
          $$RouteDiscoverySnapshotTableUpdateCompanionBuilder,
          (
            RouteDiscoverySnapshotData,
            BaseReferences<
              _$SnapshotDatabase,
              $RouteDiscoverySnapshotTable,
              RouteDiscoverySnapshotData
            >,
          ),
          RouteDiscoverySnapshotData,
          PrefetchHooks Function()
        > {
  $$RouteDiscoverySnapshotTableTableManager(
    _$SnapshotDatabase db,
    $RouteDiscoverySnapshotTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RouteDiscoverySnapshotTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RouteDiscoverySnapshotTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RouteDiscoverySnapshotTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                Value<int> formatVersion = const Value.absent(),
                Value<Uint8List> payload = const Value.absent(),
                Value<int> payloadBytes = const Value.absent(),
                Value<Uint8List> payloadSha256 = const Value.absent(),
                Value<int> capturedAtUtcMs = const Value.absent(),
                Value<int> expiresAtUtcMs = const Value.absent(),
                Value<int> lastObservedUtcMs = const Value.absent(),
              }) => RouteDiscoverySnapshotCompanion(
                slot: slot,
                formatVersion: formatVersion,
                payload: payload,
                payloadBytes: payloadBytes,
                payloadSha256: payloadSha256,
                capturedAtUtcMs: capturedAtUtcMs,
                expiresAtUtcMs: expiresAtUtcMs,
                lastObservedUtcMs: lastObservedUtcMs,
              ),
          createCompanionCallback:
              ({
                Value<int> slot = const Value.absent(),
                required int formatVersion,
                required Uint8List payload,
                required int payloadBytes,
                required Uint8List payloadSha256,
                required int capturedAtUtcMs,
                required int expiresAtUtcMs,
                required int lastObservedUtcMs,
              }) => RouteDiscoverySnapshotCompanion.insert(
                slot: slot,
                formatVersion: formatVersion,
                payload: payload,
                payloadBytes: payloadBytes,
                payloadSha256: payloadSha256,
                capturedAtUtcMs: capturedAtUtcMs,
                expiresAtUtcMs: expiresAtUtcMs,
                lastObservedUtcMs: lastObservedUtcMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RouteDiscoverySnapshotTable,
                    RouteDiscoverySnapshotData
                  >(table),
                  BaseReferences<
                    _$SnapshotDatabase,
                    $RouteDiscoverySnapshotTable,
                    RouteDiscoverySnapshotData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RouteDiscoverySnapshotTableProcessedTableManager =
    ProcessedTableManager<
      _$SnapshotDatabase,
      $RouteDiscoverySnapshotTable,
      RouteDiscoverySnapshotData,
      $$RouteDiscoverySnapshotTableFilterComposer,
      $$RouteDiscoverySnapshotTableOrderingComposer,
      $$RouteDiscoverySnapshotTableAnnotationComposer,
      $$RouteDiscoverySnapshotTableCreateCompanionBuilder,
      $$RouteDiscoverySnapshotTableUpdateCompanionBuilder,
      (
        RouteDiscoverySnapshotData,
        BaseReferences<
          _$SnapshotDatabase,
          $RouteDiscoverySnapshotTable,
          RouteDiscoverySnapshotData
        >,
      ),
      RouteDiscoverySnapshotData,
      PrefetchHooks Function()
    >;

class $SnapshotDatabaseManager {
  final _$SnapshotDatabase _db;
  $SnapshotDatabaseManager(this._db);
  $$RouteDiscoverySnapshotTableTableManager get routeDiscoverySnapshot =>
      $$RouteDiscoverySnapshotTableTableManager(
        _db,
        _db.routeDiscoverySnapshot,
      );
}
