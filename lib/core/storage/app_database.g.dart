// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SyncQueuesTable extends SyncQueues
    with TableInfo<$SyncQueuesTable, SyncQueue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    payloadJson,
    createdAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queues';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $SyncQueuesTable createAlias(String alias) {
    return $SyncQueuesTable(attachedDatabase, alias);
  }
}

class SyncQueue extends DataClass implements Insertable<SyncQueue> {
  final int id;
  final String kind;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime? syncedAt;
  const SyncQueue({
    required this.id,
    required this.kind,
    required this.payloadJson,
    required this.createdAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  SyncQueuesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueuesCompanion(
      id: Value(id),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory SyncQueue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueue(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  SyncQueue copyWith({
    int? id,
    String? kind,
    String? payloadJson,
    DateTime? createdAt,
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => SyncQueue(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SyncQueue copyWithCompanion(SyncQueuesCompanion data) {
    return SyncQueue(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueue(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, payloadJson, createdAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueue &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt);
}

class SyncQueuesCompanion extends UpdateCompanion<SyncQueue> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  const SyncQueuesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  SyncQueuesCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String payloadJson,
    required DateTime createdAt,
    this.syncedAt = const Value.absent(),
  }) : kind = Value(kind),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<SyncQueue> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  SyncQueuesCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime?>? syncedAt,
  }) {
    return SyncQueuesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueuesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $CacheProjectsTable extends CacheProjects
    with TableInfo<$CacheProjectsTable, CacheProject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payloadJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheProject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheProject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheProject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CacheProjectsTable createAlias(String alias) {
    return $CacheProjectsTable(attachedDatabase, alias);
  }
}

class CacheProject extends DataClass implements Insertable<CacheProject> {
  final String id;
  final String payloadJson;
  final String? updatedAt;
  const CacheProject({
    required this.id,
    required this.payloadJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CacheProjectsCompanion toCompanion(bool nullToAbsent) {
    return CacheProjectsCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheProject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheProject(
      id: serializer.fromJson<String>(json['id']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CacheProject copyWith({
    String? id,
    String? payloadJson,
    Value<String?> updatedAt = const Value.absent(),
  }) => CacheProject(
    id: id ?? this.id,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheProject copyWithCompanion(CacheProjectsCompanion data) {
    return CacheProject(
      id: data.id.present ? data.id.value : this.id,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheProject(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheProject &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class CacheProjectsCompanion extends UpdateCompanion<CacheProject> {
  final Value<String> id;
  final Value<String> payloadJson;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CacheProjectsCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheProjectsCompanion.insert({
    required String id,
    required String payloadJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadJson = Value(payloadJson);
  static Insertable<CacheProject> custom({
    Expression<String>? id,
    Expression<String>? payloadJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? payloadJson,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheProjectsCompanion(
      id: id ?? this.id,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheProjectsCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheTaskStatusesTable extends CacheTaskStatuses
    with TableInfo<$CacheTaskStatusesTable, CacheTaskStatuse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheTaskStatusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, projectId, payloadJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_task_statuses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheTaskStatuse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheTaskStatuse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheTaskStatuse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CacheTaskStatusesTable createAlias(String alias) {
    return $CacheTaskStatusesTable(attachedDatabase, alias);
  }
}

class CacheTaskStatuse extends DataClass
    implements Insertable<CacheTaskStatuse> {
  final String id;
  final String projectId;
  final String payloadJson;
  final String? updatedAt;
  const CacheTaskStatuse({
    required this.id,
    required this.projectId,
    required this.payloadJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CacheTaskStatusesCompanion toCompanion(bool nullToAbsent) {
    return CacheTaskStatusesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      payloadJson: Value(payloadJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheTaskStatuse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheTaskStatuse(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CacheTaskStatuse copyWith({
    String? id,
    String? projectId,
    String? payloadJson,
    Value<String?> updatedAt = const Value.absent(),
  }) => CacheTaskStatuse(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheTaskStatuse copyWithCompanion(CacheTaskStatusesCompanion data) {
    return CacheTaskStatuse(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheTaskStatuse(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheTaskStatuse &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class CacheTaskStatusesCompanion extends UpdateCompanion<CacheTaskStatuse> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> payloadJson;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CacheTaskStatusesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheTaskStatusesCompanion.insert({
    required String id,
    required String projectId,
    required String payloadJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       payloadJson = Value(payloadJson);
  static Insertable<CacheTaskStatuse> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? payloadJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheTaskStatusesCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? payloadJson,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheTaskStatusesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheTaskStatusesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheTasksTable extends CacheTasks
    with TableInfo<$CacheTasksTable, CacheTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, projectId, payloadJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CacheTasksTable createAlias(String alias) {
    return $CacheTasksTable(attachedDatabase, alias);
  }
}

class CacheTask extends DataClass implements Insertable<CacheTask> {
  final String id;
  final String projectId;
  final String payloadJson;
  final String? updatedAt;
  const CacheTask({
    required this.id,
    required this.projectId,
    required this.payloadJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CacheTasksCompanion toCompanion(bool nullToAbsent) {
    return CacheTasksCompanion(
      id: Value(id),
      projectId: Value(projectId),
      payloadJson: Value(payloadJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheTask(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CacheTask copyWith({
    String? id,
    String? projectId,
    String? payloadJson,
    Value<String?> updatedAt = const Value.absent(),
  }) => CacheTask(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheTask copyWithCompanion(CacheTasksCompanion data) {
    return CacheTask(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheTask(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheTask &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class CacheTasksCompanion extends UpdateCompanion<CacheTask> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> payloadJson;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CacheTasksCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheTasksCompanion.insert({
    required String id,
    required String projectId,
    required String payloadJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       payloadJson = Value(payloadJson);
  static Insertable<CacheTask> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? payloadJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheTasksCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? payloadJson,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheTasksCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheTasksCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheTaskUpdatesTable extends CacheTaskUpdates
    with TableInfo<$CacheTaskUpdatesTable, CacheTaskUpdate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheTaskUpdatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    projectId,
    payloadJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_task_updates';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheTaskUpdate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheTaskUpdate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheTaskUpdate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CacheTaskUpdatesTable createAlias(String alias) {
    return $CacheTaskUpdatesTable(attachedDatabase, alias);
  }
}

class CacheTaskUpdate extends DataClass implements Insertable<CacheTaskUpdate> {
  final String id;
  final String taskId;
  final String projectId;
  final String payloadJson;
  final String? updatedAt;
  const CacheTaskUpdate({
    required this.id,
    required this.taskId,
    required this.projectId,
    required this.payloadJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['project_id'] = Variable<String>(projectId);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CacheTaskUpdatesCompanion toCompanion(bool nullToAbsent) {
    return CacheTaskUpdatesCompanion(
      id: Value(id),
      taskId: Value(taskId),
      projectId: Value(projectId),
      payloadJson: Value(payloadJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheTaskUpdate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheTaskUpdate(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'projectId': serializer.toJson<String>(projectId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CacheTaskUpdate copyWith({
    String? id,
    String? taskId,
    String? projectId,
    String? payloadJson,
    Value<String?> updatedAt = const Value.absent(),
  }) => CacheTaskUpdate(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    projectId: projectId ?? this.projectId,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheTaskUpdate copyWithCompanion(CacheTaskUpdatesCompanion data) {
    return CacheTaskUpdate(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheTaskUpdate(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, taskId, projectId, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheTaskUpdate &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.projectId == this.projectId &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class CacheTaskUpdatesCompanion extends UpdateCompanion<CacheTaskUpdate> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> projectId;
  final Value<String> payloadJson;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CacheTaskUpdatesCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheTaskUpdatesCompanion.insert({
    required String id,
    required String taskId,
    required String projectId,
    required String payloadJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       projectId = Value(projectId),
       payloadJson = Value(payloadJson);
  static Insertable<CacheTaskUpdate> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? projectId,
    Expression<String>? payloadJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (projectId != null) 'project_id': projectId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheTaskUpdatesCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? projectId,
    Value<String>? payloadJson,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheTaskUpdatesCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      projectId: projectId ?? this.projectId,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheTaskUpdatesCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheAttendanceTable extends CacheAttendance
    with TableInfo<$CacheAttendanceTable, CacheAttendanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheAttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, projectId, payloadJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheAttendanceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheAttendanceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheAttendanceData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CacheAttendanceTable createAlias(String alias) {
    return $CacheAttendanceTable(attachedDatabase, alias);
  }
}

class CacheAttendanceData extends DataClass
    implements Insertable<CacheAttendanceData> {
  final String id;
  final String projectId;
  final String payloadJson;
  final String? updatedAt;
  const CacheAttendanceData({
    required this.id,
    required this.projectId,
    required this.payloadJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CacheAttendanceCompanion toCompanion(bool nullToAbsent) {
    return CacheAttendanceCompanion(
      id: Value(id),
      projectId: Value(projectId),
      payloadJson: Value(payloadJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheAttendanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheAttendanceData(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CacheAttendanceData copyWith({
    String? id,
    String? projectId,
    String? payloadJson,
    Value<String?> updatedAt = const Value.absent(),
  }) => CacheAttendanceData(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheAttendanceData copyWithCompanion(CacheAttendanceCompanion data) {
    return CacheAttendanceData(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheAttendanceData(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheAttendanceData &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class CacheAttendanceCompanion extends UpdateCompanion<CacheAttendanceData> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> payloadJson;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CacheAttendanceCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheAttendanceCompanion.insert({
    required String id,
    required String projectId,
    required String payloadJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       payloadJson = Value(payloadJson);
  static Insertable<CacheAttendanceData> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? payloadJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheAttendanceCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? payloadJson,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheAttendanceCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheAttendanceCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheDailyReportEntriesTable extends CacheDailyReportEntries
    with TableInfo<$CacheDailyReportEntriesTable, CacheDailyReportEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheDailyReportEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reportDateMeta = const VerificationMeta(
    'reportDate',
  );
  @override
  late final GeneratedColumn<String> reportDate = GeneratedColumn<String>(
    'report_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    reportDate,
    payloadJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_daily_report_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheDailyReportEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('report_date')) {
      context.handle(
        _reportDateMeta,
        reportDate.isAcceptableOrUnknown(data['report_date']!, _reportDateMeta),
      );
    } else if (isInserting) {
      context.missing(_reportDateMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheDailyReportEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheDailyReportEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      reportDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_date'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CacheDailyReportEntriesTable createAlias(String alias) {
    return $CacheDailyReportEntriesTable(attachedDatabase, alias);
  }
}

class CacheDailyReportEntry extends DataClass
    implements Insertable<CacheDailyReportEntry> {
  final String id;
  final String projectId;
  final String reportDate;
  final String payloadJson;
  final String? updatedAt;
  const CacheDailyReportEntry({
    required this.id,
    required this.projectId,
    required this.reportDate,
    required this.payloadJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['report_date'] = Variable<String>(reportDate);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CacheDailyReportEntriesCompanion toCompanion(bool nullToAbsent) {
    return CacheDailyReportEntriesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      reportDate: Value(reportDate),
      payloadJson: Value(payloadJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheDailyReportEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheDailyReportEntry(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      reportDate: serializer.fromJson<String>(json['reportDate']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'reportDate': serializer.toJson<String>(reportDate),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CacheDailyReportEntry copyWith({
    String? id,
    String? projectId,
    String? reportDate,
    String? payloadJson,
    Value<String?> updatedAt = const Value.absent(),
  }) => CacheDailyReportEntry(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    reportDate: reportDate ?? this.reportDate,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheDailyReportEntry copyWithCompanion(
    CacheDailyReportEntriesCompanion data,
  ) {
    return CacheDailyReportEntry(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      reportDate: data.reportDate.present
          ? data.reportDate.value
          : this.reportDate,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheDailyReportEntry(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('reportDate: $reportDate, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, reportDate, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheDailyReportEntry &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.reportDate == this.reportDate &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class CacheDailyReportEntriesCompanion
    extends UpdateCompanion<CacheDailyReportEntry> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> reportDate;
  final Value<String> payloadJson;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CacheDailyReportEntriesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.reportDate = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheDailyReportEntriesCompanion.insert({
    required String id,
    required String projectId,
    required String reportDate,
    required String payloadJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       reportDate = Value(reportDate),
       payloadJson = Value(payloadJson);
  static Insertable<CacheDailyReportEntry> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? reportDate,
    Expression<String>? payloadJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (reportDate != null) 'report_date': reportDate,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheDailyReportEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? reportDate,
    Value<String>? payloadJson,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheDailyReportEntriesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      reportDate: reportDate ?? this.reportDate,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (reportDate.present) {
      map['report_date'] = Variable<String>(reportDate.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheDailyReportEntriesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('reportDate: $reportDate, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheExpenseTransactionsTable extends CacheExpenseTransactions
    with TableInfo<$CacheExpenseTransactionsTable, CacheExpenseTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheExpenseTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, projectId, payloadJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_expense_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheExpenseTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheExpenseTransaction map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheExpenseTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CacheExpenseTransactionsTable createAlias(String alias) {
    return $CacheExpenseTransactionsTable(attachedDatabase, alias);
  }
}

class CacheExpenseTransaction extends DataClass
    implements Insertable<CacheExpenseTransaction> {
  final String id;
  final String projectId;
  final String payloadJson;
  final String? updatedAt;
  const CacheExpenseTransaction({
    required this.id,
    required this.projectId,
    required this.payloadJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CacheExpenseTransactionsCompanion toCompanion(bool nullToAbsent) {
    return CacheExpenseTransactionsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      payloadJson: Value(payloadJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheExpenseTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheExpenseTransaction(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CacheExpenseTransaction copyWith({
    String? id,
    String? projectId,
    String? payloadJson,
    Value<String?> updatedAt = const Value.absent(),
  }) => CacheExpenseTransaction(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheExpenseTransaction copyWithCompanion(
    CacheExpenseTransactionsCompanion data,
  ) {
    return CacheExpenseTransaction(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheExpenseTransaction(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheExpenseTransaction &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class CacheExpenseTransactionsCompanion
    extends UpdateCompanion<CacheExpenseTransaction> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> payloadJson;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CacheExpenseTransactionsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheExpenseTransactionsCompanion.insert({
    required String id,
    required String projectId,
    required String payloadJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       payloadJson = Value(payloadJson);
  static Insertable<CacheExpenseTransaction> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? payloadJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheExpenseTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? payloadJson,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheExpenseTransactionsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheExpenseTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheWalletBalanceTable extends CacheWalletBalance
    with TableInfo<$CacheWalletBalanceTable, CacheWalletBalanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheWalletBalanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [projectId, balance, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_wallet_balance';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheWalletBalanceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {projectId};
  @override
  CacheWalletBalanceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheWalletBalanceData(
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CacheWalletBalanceTable createAlias(String alias) {
    return $CacheWalletBalanceTable(attachedDatabase, alias);
  }
}

class CacheWalletBalanceData extends DataClass
    implements Insertable<CacheWalletBalanceData> {
  final String projectId;
  final double balance;
  final String? updatedAt;
  const CacheWalletBalanceData({
    required this.projectId,
    required this.balance,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['project_id'] = Variable<String>(projectId);
    map['balance'] = Variable<double>(balance);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CacheWalletBalanceCompanion toCompanion(bool nullToAbsent) {
    return CacheWalletBalanceCompanion(
      projectId: Value(projectId),
      balance: Value(balance),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheWalletBalanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheWalletBalanceData(
      projectId: serializer.fromJson<String>(json['projectId']),
      balance: serializer.fromJson<double>(json['balance']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectId': serializer.toJson<String>(projectId),
      'balance': serializer.toJson<double>(balance),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CacheWalletBalanceData copyWith({
    String? projectId,
    double? balance,
    Value<String?> updatedAt = const Value.absent(),
  }) => CacheWalletBalanceData(
    projectId: projectId ?? this.projectId,
    balance: balance ?? this.balance,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheWalletBalanceData copyWithCompanion(CacheWalletBalanceCompanion data) {
    return CacheWalletBalanceData(
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      balance: data.balance.present ? data.balance.value : this.balance,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheWalletBalanceData(')
          ..write('projectId: $projectId, ')
          ..write('balance: $balance, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(projectId, balance, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheWalletBalanceData &&
          other.projectId == this.projectId &&
          other.balance == this.balance &&
          other.updatedAt == this.updatedAt);
}

class CacheWalletBalanceCompanion
    extends UpdateCompanion<CacheWalletBalanceData> {
  final Value<String> projectId;
  final Value<double> balance;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CacheWalletBalanceCompanion({
    this.projectId = const Value.absent(),
    this.balance = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheWalletBalanceCompanion.insert({
    required String projectId,
    required double balance,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       balance = Value(balance);
  static Insertable<CacheWalletBalanceData> custom({
    Expression<String>? projectId,
    Expression<double>? balance,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectId != null) 'project_id': projectId,
      if (balance != null) 'balance': balance,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheWalletBalanceCompanion copyWith({
    Value<String>? projectId,
    Value<double>? balance,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheWalletBalanceCompanion(
      projectId: projectId ?? this.projectId,
      balance: balance ?? this.balance,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheWalletBalanceCompanion(')
          ..write('projectId: $projectId, ')
          ..write('balance: $balance, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheMasterMaterialsTable extends CacheMasterMaterials
    with TableInfo<$CacheMasterMaterialsTable, CacheMasterMaterial> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheMasterMaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payloadJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_master_materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheMasterMaterial> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheMasterMaterial map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheMasterMaterial(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CacheMasterMaterialsTable createAlias(String alias) {
    return $CacheMasterMaterialsTable(attachedDatabase, alias);
  }
}

class CacheMasterMaterial extends DataClass
    implements Insertable<CacheMasterMaterial> {
  final String id;
  final String payloadJson;
  final String? updatedAt;
  const CacheMasterMaterial({
    required this.id,
    required this.payloadJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CacheMasterMaterialsCompanion toCompanion(bool nullToAbsent) {
    return CacheMasterMaterialsCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheMasterMaterial.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheMasterMaterial(
      id: serializer.fromJson<String>(json['id']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CacheMasterMaterial copyWith({
    String? id,
    String? payloadJson,
    Value<String?> updatedAt = const Value.absent(),
  }) => CacheMasterMaterial(
    id: id ?? this.id,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheMasterMaterial copyWithCompanion(CacheMasterMaterialsCompanion data) {
    return CacheMasterMaterial(
      id: data.id.present ? data.id.value : this.id,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheMasterMaterial(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheMasterMaterial &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class CacheMasterMaterialsCompanion
    extends UpdateCompanion<CacheMasterMaterial> {
  final Value<String> id;
  final Value<String> payloadJson;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CacheMasterMaterialsCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheMasterMaterialsCompanion.insert({
    required String id,
    required String payloadJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadJson = Value(payloadJson);
  static Insertable<CacheMasterMaterial> custom({
    Expression<String>? id,
    Expression<String>? payloadJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheMasterMaterialsCompanion copyWith({
    Value<String>? id,
    Value<String>? payloadJson,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheMasterMaterialsCompanion(
      id: id ?? this.id,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheMasterMaterialsCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheMaterialsTable extends CacheMaterials
    with TableInfo<$CacheMaterialsTable, CacheMaterial> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheMaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, projectId, payloadJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheMaterial> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheMaterial map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheMaterial(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CacheMaterialsTable createAlias(String alias) {
    return $CacheMaterialsTable(attachedDatabase, alias);
  }
}

class CacheMaterial extends DataClass implements Insertable<CacheMaterial> {
  final String id;
  final String projectId;
  final String payloadJson;
  final String? updatedAt;
  const CacheMaterial({
    required this.id,
    required this.projectId,
    required this.payloadJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CacheMaterialsCompanion toCompanion(bool nullToAbsent) {
    return CacheMaterialsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      payloadJson: Value(payloadJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheMaterial.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheMaterial(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CacheMaterial copyWith({
    String? id,
    String? projectId,
    String? payloadJson,
    Value<String?> updatedAt = const Value.absent(),
  }) => CacheMaterial(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheMaterial copyWithCompanion(CacheMaterialsCompanion data) {
    return CacheMaterial(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheMaterial(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheMaterial &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class CacheMaterialsCompanion extends UpdateCompanion<CacheMaterial> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> payloadJson;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CacheMaterialsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheMaterialsCompanion.insert({
    required String id,
    required String projectId,
    required String payloadJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       payloadJson = Value(payloadJson);
  static Insertable<CacheMaterial> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? payloadJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheMaterialsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? payloadJson,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheMaterialsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheMaterialsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheMaterialLedgerTable extends CacheMaterialLedger
    with TableInfo<$CacheMaterialLedgerTable, CacheMaterialLedgerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheMaterialLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _materialIdMeta = const VerificationMeta(
    'materialId',
  );
  @override
  late final GeneratedColumn<String> materialId = GeneratedColumn<String>(
    'material_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    materialId,
    payloadJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_material_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheMaterialLedgerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('material_id')) {
      context.handle(
        _materialIdMeta,
        materialId.isAcceptableOrUnknown(data['material_id']!, _materialIdMeta),
      );
    } else if (isInserting) {
      context.missing(_materialIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CacheMaterialLedgerData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheMaterialLedgerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      materialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $CacheMaterialLedgerTable createAlias(String alias) {
    return $CacheMaterialLedgerTable(attachedDatabase, alias);
  }
}

class CacheMaterialLedgerData extends DataClass
    implements Insertable<CacheMaterialLedgerData> {
  final String id;
  final String projectId;
  final String materialId;
  final String payloadJson;
  final String? updatedAt;
  const CacheMaterialLedgerData({
    required this.id,
    required this.projectId,
    required this.materialId,
    required this.payloadJson,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['material_id'] = Variable<String>(materialId);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    return map;
  }

  CacheMaterialLedgerCompanion toCompanion(bool nullToAbsent) {
    return CacheMaterialLedgerCompanion(
      id: Value(id),
      projectId: Value(projectId),
      materialId: Value(materialId),
      payloadJson: Value(payloadJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CacheMaterialLedgerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheMaterialLedgerData(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      materialId: serializer.fromJson<String>(json['materialId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'materialId': serializer.toJson<String>(materialId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<String?>(updatedAt),
    };
  }

  CacheMaterialLedgerData copyWith({
    String? id,
    String? projectId,
    String? materialId,
    String? payloadJson,
    Value<String?> updatedAt = const Value.absent(),
  }) => CacheMaterialLedgerData(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    materialId: materialId ?? this.materialId,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CacheMaterialLedgerData copyWithCompanion(CacheMaterialLedgerCompanion data) {
    return CacheMaterialLedgerData(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      materialId: data.materialId.present
          ? data.materialId.value
          : this.materialId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheMaterialLedgerData(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('materialId: $materialId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, materialId, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheMaterialLedgerData &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.materialId == this.materialId &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class CacheMaterialLedgerCompanion
    extends UpdateCompanion<CacheMaterialLedgerData> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> materialId;
  final Value<String> payloadJson;
  final Value<String?> updatedAt;
  final Value<int> rowid;
  const CacheMaterialLedgerCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheMaterialLedgerCompanion.insert({
    required String id,
    required String projectId,
    required String materialId,
    required String payloadJson,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       materialId = Value(materialId),
       payloadJson = Value(payloadJson);
  static Insertable<CacheMaterialLedgerData> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? materialId,
    Expression<String>? payloadJson,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (materialId != null) 'material_id': materialId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheMaterialLedgerCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? materialId,
    Value<String>? payloadJson,
    Value<String?>? updatedAt,
    Value<int>? rowid,
  }) {
    return CacheMaterialLedgerCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      materialId: materialId ?? this.materialId,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<String>(materialId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheMaterialLedgerCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('materialId: $materialId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPullAtMeta = const VerificationMeta(
    'lastPullAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPullAt = GeneratedColumn<DateTime>(
    'last_pull_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entityType, lastPullAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('last_pull_at')) {
      context.handle(
        _lastPullAtMeta,
        lastPullAt.isAcceptableOrUnknown(
          data['last_pull_at']!,
          _lastPullAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastPullAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      lastPullAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pull_at'],
      )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String entityType;
  final DateTime lastPullAt;
  const SyncMetadataData({required this.entityType, required this.lastPullAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['last_pull_at'] = Variable<DateTime>(lastPullAt);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      entityType: Value(entityType),
      lastPullAt: Value(lastPullAt),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      entityType: serializer.fromJson<String>(json['entityType']),
      lastPullAt: serializer.fromJson<DateTime>(json['lastPullAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'lastPullAt': serializer.toJson<DateTime>(lastPullAt),
    };
  }

  SyncMetadataData copyWith({String? entityType, DateTime? lastPullAt}) =>
      SyncMetadataData(
        entityType: entityType ?? this.entityType,
        lastPullAt: lastPullAt ?? this.lastPullAt,
      );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      lastPullAt: data.lastPullAt.present
          ? data.lastPullAt.value
          : this.lastPullAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('entityType: $entityType, ')
          ..write('lastPullAt: $lastPullAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, lastPullAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.entityType == this.entityType &&
          other.lastPullAt == this.lastPullAt);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> entityType;
  final Value<DateTime> lastPullAt;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.entityType = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String entityType,
    required DateTime lastPullAt,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       lastPullAt = Value(lastPullAt);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? entityType,
    Expression<DateTime>? lastPullAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (lastPullAt != null) 'last_pull_at': lastPullAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? entityType,
    Value<DateTime>? lastPullAt,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      entityType: entityType ?? this.entityType,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (lastPullAt.present) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('entityType: $entityType, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SyncQueuesTable syncQueues = $SyncQueuesTable(this);
  late final $CacheProjectsTable cacheProjects = $CacheProjectsTable(this);
  late final $CacheTaskStatusesTable cacheTaskStatuses =
      $CacheTaskStatusesTable(this);
  late final $CacheTasksTable cacheTasks = $CacheTasksTable(this);
  late final $CacheTaskUpdatesTable cacheTaskUpdates = $CacheTaskUpdatesTable(
    this,
  );
  late final $CacheAttendanceTable cacheAttendance = $CacheAttendanceTable(
    this,
  );
  late final $CacheDailyReportEntriesTable cacheDailyReportEntries =
      $CacheDailyReportEntriesTable(this);
  late final $CacheExpenseTransactionsTable cacheExpenseTransactions =
      $CacheExpenseTransactionsTable(this);
  late final $CacheWalletBalanceTable cacheWalletBalance =
      $CacheWalletBalanceTable(this);
  late final $CacheMasterMaterialsTable cacheMasterMaterials =
      $CacheMasterMaterialsTable(this);
  late final $CacheMaterialsTable cacheMaterials = $CacheMaterialsTable(this);
  late final $CacheMaterialLedgerTable cacheMaterialLedger =
      $CacheMaterialLedgerTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    syncQueues,
    cacheProjects,
    cacheTaskStatuses,
    cacheTasks,
    cacheTaskUpdates,
    cacheAttendance,
    cacheDailyReportEntries,
    cacheExpenseTransactions,
    cacheWalletBalance,
    cacheMasterMaterials,
    cacheMaterials,
    cacheMaterialLedger,
    syncMetadata,
  ];
}

typedef $$SyncQueuesTableCreateCompanionBuilder =
    SyncQueuesCompanion Function({
      Value<int> id,
      required String kind,
      required String payloadJson,
      required DateTime createdAt,
      Value<DateTime?> syncedAt,
    });
typedef $$SyncQueuesTableUpdateCompanionBuilder =
    SyncQueuesCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime?> syncedAt,
    });

class $$SyncQueuesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueuesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueuesTable> {
  $$SyncQueuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SyncQueuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueuesTable,
          SyncQueue,
          $$SyncQueuesTableFilterComposer,
          $$SyncQueuesTableOrderingComposer,
          $$SyncQueuesTableAnnotationComposer,
          $$SyncQueuesTableCreateCompanionBuilder,
          $$SyncQueuesTableUpdateCompanionBuilder,
          (
            SyncQueue,
            BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>,
          ),
          SyncQueue,
          PrefetchHooks Function()
        > {
  $$SyncQueuesTableTableManager(_$AppDatabase db, $SyncQueuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => SyncQueuesCompanion(
                id: id,
                kind: kind,
                payloadJson: payloadJson,
                createdAt: createdAt,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String payloadJson,
                required DateTime createdAt,
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => SyncQueuesCompanion.insert(
                id: id,
                kind: kind,
                payloadJson: payloadJson,
                createdAt: createdAt,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueuesTable,
      SyncQueue,
      $$SyncQueuesTableFilterComposer,
      $$SyncQueuesTableOrderingComposer,
      $$SyncQueuesTableAnnotationComposer,
      $$SyncQueuesTableCreateCompanionBuilder,
      $$SyncQueuesTableUpdateCompanionBuilder,
      (SyncQueue, BaseReferences<_$AppDatabase, $SyncQueuesTable, SyncQueue>),
      SyncQueue,
      PrefetchHooks Function()
    >;
typedef $$CacheProjectsTableCreateCompanionBuilder =
    CacheProjectsCompanion Function({
      required String id,
      required String payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheProjectsTableUpdateCompanionBuilder =
    CacheProjectsCompanion Function({
      Value<String> id,
      Value<String> payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CacheProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $CacheProjectsTable> {
  $$CacheProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheProjectsTable> {
  $$CacheProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheProjectsTable> {
  $$CacheProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheProjectsTable,
          CacheProject,
          $$CacheProjectsTableFilterComposer,
          $$CacheProjectsTableOrderingComposer,
          $$CacheProjectsTableAnnotationComposer,
          $$CacheProjectsTableCreateCompanionBuilder,
          $$CacheProjectsTableUpdateCompanionBuilder,
          (
            CacheProject,
            BaseReferences<_$AppDatabase, $CacheProjectsTable, CacheProject>,
          ),
          CacheProject,
          PrefetchHooks Function()
        > {
  $$CacheProjectsTableTableManager(_$AppDatabase db, $CacheProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheProjectsCompanion(
                id: id,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payloadJson,
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheProjectsCompanion.insert(
                id: id,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheProjectsTable,
      CacheProject,
      $$CacheProjectsTableFilterComposer,
      $$CacheProjectsTableOrderingComposer,
      $$CacheProjectsTableAnnotationComposer,
      $$CacheProjectsTableCreateCompanionBuilder,
      $$CacheProjectsTableUpdateCompanionBuilder,
      (
        CacheProject,
        BaseReferences<_$AppDatabase, $CacheProjectsTable, CacheProject>,
      ),
      CacheProject,
      PrefetchHooks Function()
    >;
typedef $$CacheTaskStatusesTableCreateCompanionBuilder =
    CacheTaskStatusesCompanion Function({
      required String id,
      required String projectId,
      required String payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheTaskStatusesTableUpdateCompanionBuilder =
    CacheTaskStatusesCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CacheTaskStatusesTableFilterComposer
    extends Composer<_$AppDatabase, $CacheTaskStatusesTable> {
  $$CacheTaskStatusesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheTaskStatusesTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheTaskStatusesTable> {
  $$CacheTaskStatusesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheTaskStatusesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheTaskStatusesTable> {
  $$CacheTaskStatusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheTaskStatusesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheTaskStatusesTable,
          CacheTaskStatuse,
          $$CacheTaskStatusesTableFilterComposer,
          $$CacheTaskStatusesTableOrderingComposer,
          $$CacheTaskStatusesTableAnnotationComposer,
          $$CacheTaskStatusesTableCreateCompanionBuilder,
          $$CacheTaskStatusesTableUpdateCompanionBuilder,
          (
            CacheTaskStatuse,
            BaseReferences<
              _$AppDatabase,
              $CacheTaskStatusesTable,
              CacheTaskStatuse
            >,
          ),
          CacheTaskStatuse,
          PrefetchHooks Function()
        > {
  $$CacheTaskStatusesTableTableManager(
    _$AppDatabase db,
    $CacheTaskStatusesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheTaskStatusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheTaskStatusesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheTaskStatusesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheTaskStatusesCompanion(
                id: id,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String payloadJson,
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheTaskStatusesCompanion.insert(
                id: id,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheTaskStatusesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheTaskStatusesTable,
      CacheTaskStatuse,
      $$CacheTaskStatusesTableFilterComposer,
      $$CacheTaskStatusesTableOrderingComposer,
      $$CacheTaskStatusesTableAnnotationComposer,
      $$CacheTaskStatusesTableCreateCompanionBuilder,
      $$CacheTaskStatusesTableUpdateCompanionBuilder,
      (
        CacheTaskStatuse,
        BaseReferences<
          _$AppDatabase,
          $CacheTaskStatusesTable,
          CacheTaskStatuse
        >,
      ),
      CacheTaskStatuse,
      PrefetchHooks Function()
    >;
typedef $$CacheTasksTableCreateCompanionBuilder =
    CacheTasksCompanion Function({
      required String id,
      required String projectId,
      required String payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheTasksTableUpdateCompanionBuilder =
    CacheTasksCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CacheTasksTableFilterComposer
    extends Composer<_$AppDatabase, $CacheTasksTable> {
  $$CacheTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheTasksTable> {
  $$CacheTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheTasksTable> {
  $$CacheTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheTasksTable,
          CacheTask,
          $$CacheTasksTableFilterComposer,
          $$CacheTasksTableOrderingComposer,
          $$CacheTasksTableAnnotationComposer,
          $$CacheTasksTableCreateCompanionBuilder,
          $$CacheTasksTableUpdateCompanionBuilder,
          (
            CacheTask,
            BaseReferences<_$AppDatabase, $CacheTasksTable, CacheTask>,
          ),
          CacheTask,
          PrefetchHooks Function()
        > {
  $$CacheTasksTableTableManager(_$AppDatabase db, $CacheTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheTasksCompanion(
                id: id,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String payloadJson,
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheTasksCompanion.insert(
                id: id,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheTasksTable,
      CacheTask,
      $$CacheTasksTableFilterComposer,
      $$CacheTasksTableOrderingComposer,
      $$CacheTasksTableAnnotationComposer,
      $$CacheTasksTableCreateCompanionBuilder,
      $$CacheTasksTableUpdateCompanionBuilder,
      (CacheTask, BaseReferences<_$AppDatabase, $CacheTasksTable, CacheTask>),
      CacheTask,
      PrefetchHooks Function()
    >;
typedef $$CacheTaskUpdatesTableCreateCompanionBuilder =
    CacheTaskUpdatesCompanion Function({
      required String id,
      required String taskId,
      required String projectId,
      required String payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheTaskUpdatesTableUpdateCompanionBuilder =
    CacheTaskUpdatesCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> projectId,
      Value<String> payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CacheTaskUpdatesTableFilterComposer
    extends Composer<_$AppDatabase, $CacheTaskUpdatesTable> {
  $$CacheTaskUpdatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheTaskUpdatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheTaskUpdatesTable> {
  $$CacheTaskUpdatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheTaskUpdatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheTaskUpdatesTable> {
  $$CacheTaskUpdatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheTaskUpdatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheTaskUpdatesTable,
          CacheTaskUpdate,
          $$CacheTaskUpdatesTableFilterComposer,
          $$CacheTaskUpdatesTableOrderingComposer,
          $$CacheTaskUpdatesTableAnnotationComposer,
          $$CacheTaskUpdatesTableCreateCompanionBuilder,
          $$CacheTaskUpdatesTableUpdateCompanionBuilder,
          (
            CacheTaskUpdate,
            BaseReferences<
              _$AppDatabase,
              $CacheTaskUpdatesTable,
              CacheTaskUpdate
            >,
          ),
          CacheTaskUpdate,
          PrefetchHooks Function()
        > {
  $$CacheTaskUpdatesTableTableManager(
    _$AppDatabase db,
    $CacheTaskUpdatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheTaskUpdatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheTaskUpdatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheTaskUpdatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheTaskUpdatesCompanion(
                id: id,
                taskId: taskId,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String projectId,
                required String payloadJson,
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheTaskUpdatesCompanion.insert(
                id: id,
                taskId: taskId,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheTaskUpdatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheTaskUpdatesTable,
      CacheTaskUpdate,
      $$CacheTaskUpdatesTableFilterComposer,
      $$CacheTaskUpdatesTableOrderingComposer,
      $$CacheTaskUpdatesTableAnnotationComposer,
      $$CacheTaskUpdatesTableCreateCompanionBuilder,
      $$CacheTaskUpdatesTableUpdateCompanionBuilder,
      (
        CacheTaskUpdate,
        BaseReferences<_$AppDatabase, $CacheTaskUpdatesTable, CacheTaskUpdate>,
      ),
      CacheTaskUpdate,
      PrefetchHooks Function()
    >;
typedef $$CacheAttendanceTableCreateCompanionBuilder =
    CacheAttendanceCompanion Function({
      required String id,
      required String projectId,
      required String payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheAttendanceTableUpdateCompanionBuilder =
    CacheAttendanceCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CacheAttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $CacheAttendanceTable> {
  $$CacheAttendanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheAttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheAttendanceTable> {
  $$CacheAttendanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheAttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheAttendanceTable> {
  $$CacheAttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheAttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheAttendanceTable,
          CacheAttendanceData,
          $$CacheAttendanceTableFilterComposer,
          $$CacheAttendanceTableOrderingComposer,
          $$CacheAttendanceTableAnnotationComposer,
          $$CacheAttendanceTableCreateCompanionBuilder,
          $$CacheAttendanceTableUpdateCompanionBuilder,
          (
            CacheAttendanceData,
            BaseReferences<
              _$AppDatabase,
              $CacheAttendanceTable,
              CacheAttendanceData
            >,
          ),
          CacheAttendanceData,
          PrefetchHooks Function()
        > {
  $$CacheAttendanceTableTableManager(
    _$AppDatabase db,
    $CacheAttendanceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheAttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheAttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheAttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheAttendanceCompanion(
                id: id,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String payloadJson,
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheAttendanceCompanion.insert(
                id: id,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheAttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheAttendanceTable,
      CacheAttendanceData,
      $$CacheAttendanceTableFilterComposer,
      $$CacheAttendanceTableOrderingComposer,
      $$CacheAttendanceTableAnnotationComposer,
      $$CacheAttendanceTableCreateCompanionBuilder,
      $$CacheAttendanceTableUpdateCompanionBuilder,
      (
        CacheAttendanceData,
        BaseReferences<
          _$AppDatabase,
          $CacheAttendanceTable,
          CacheAttendanceData
        >,
      ),
      CacheAttendanceData,
      PrefetchHooks Function()
    >;
typedef $$CacheDailyReportEntriesTableCreateCompanionBuilder =
    CacheDailyReportEntriesCompanion Function({
      required String id,
      required String projectId,
      required String reportDate,
      required String payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheDailyReportEntriesTableUpdateCompanionBuilder =
    CacheDailyReportEntriesCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> reportDate,
      Value<String> payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CacheDailyReportEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CacheDailyReportEntriesTable> {
  $$CacheDailyReportEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheDailyReportEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheDailyReportEntriesTable> {
  $$CacheDailyReportEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheDailyReportEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheDailyReportEntriesTable> {
  $$CacheDailyReportEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheDailyReportEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheDailyReportEntriesTable,
          CacheDailyReportEntry,
          $$CacheDailyReportEntriesTableFilterComposer,
          $$CacheDailyReportEntriesTableOrderingComposer,
          $$CacheDailyReportEntriesTableAnnotationComposer,
          $$CacheDailyReportEntriesTableCreateCompanionBuilder,
          $$CacheDailyReportEntriesTableUpdateCompanionBuilder,
          (
            CacheDailyReportEntry,
            BaseReferences<
              _$AppDatabase,
              $CacheDailyReportEntriesTable,
              CacheDailyReportEntry
            >,
          ),
          CacheDailyReportEntry,
          PrefetchHooks Function()
        > {
  $$CacheDailyReportEntriesTableTableManager(
    _$AppDatabase db,
    $CacheDailyReportEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheDailyReportEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CacheDailyReportEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CacheDailyReportEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> reportDate = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheDailyReportEntriesCompanion(
                id: id,
                projectId: projectId,
                reportDate: reportDate,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String reportDate,
                required String payloadJson,
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheDailyReportEntriesCompanion.insert(
                id: id,
                projectId: projectId,
                reportDate: reportDate,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheDailyReportEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheDailyReportEntriesTable,
      CacheDailyReportEntry,
      $$CacheDailyReportEntriesTableFilterComposer,
      $$CacheDailyReportEntriesTableOrderingComposer,
      $$CacheDailyReportEntriesTableAnnotationComposer,
      $$CacheDailyReportEntriesTableCreateCompanionBuilder,
      $$CacheDailyReportEntriesTableUpdateCompanionBuilder,
      (
        CacheDailyReportEntry,
        BaseReferences<
          _$AppDatabase,
          $CacheDailyReportEntriesTable,
          CacheDailyReportEntry
        >,
      ),
      CacheDailyReportEntry,
      PrefetchHooks Function()
    >;
typedef $$CacheExpenseTransactionsTableCreateCompanionBuilder =
    CacheExpenseTransactionsCompanion Function({
      required String id,
      required String projectId,
      required String payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheExpenseTransactionsTableUpdateCompanionBuilder =
    CacheExpenseTransactionsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CacheExpenseTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $CacheExpenseTransactionsTable> {
  $$CacheExpenseTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheExpenseTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheExpenseTransactionsTable> {
  $$CacheExpenseTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheExpenseTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheExpenseTransactionsTable> {
  $$CacheExpenseTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheExpenseTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheExpenseTransactionsTable,
          CacheExpenseTransaction,
          $$CacheExpenseTransactionsTableFilterComposer,
          $$CacheExpenseTransactionsTableOrderingComposer,
          $$CacheExpenseTransactionsTableAnnotationComposer,
          $$CacheExpenseTransactionsTableCreateCompanionBuilder,
          $$CacheExpenseTransactionsTableUpdateCompanionBuilder,
          (
            CacheExpenseTransaction,
            BaseReferences<
              _$AppDatabase,
              $CacheExpenseTransactionsTable,
              CacheExpenseTransaction
            >,
          ),
          CacheExpenseTransaction,
          PrefetchHooks Function()
        > {
  $$CacheExpenseTransactionsTableTableManager(
    _$AppDatabase db,
    $CacheExpenseTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheExpenseTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CacheExpenseTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CacheExpenseTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheExpenseTransactionsCompanion(
                id: id,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String payloadJson,
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheExpenseTransactionsCompanion.insert(
                id: id,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheExpenseTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheExpenseTransactionsTable,
      CacheExpenseTransaction,
      $$CacheExpenseTransactionsTableFilterComposer,
      $$CacheExpenseTransactionsTableOrderingComposer,
      $$CacheExpenseTransactionsTableAnnotationComposer,
      $$CacheExpenseTransactionsTableCreateCompanionBuilder,
      $$CacheExpenseTransactionsTableUpdateCompanionBuilder,
      (
        CacheExpenseTransaction,
        BaseReferences<
          _$AppDatabase,
          $CacheExpenseTransactionsTable,
          CacheExpenseTransaction
        >,
      ),
      CacheExpenseTransaction,
      PrefetchHooks Function()
    >;
typedef $$CacheWalletBalanceTableCreateCompanionBuilder =
    CacheWalletBalanceCompanion Function({
      required String projectId,
      required double balance,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheWalletBalanceTableUpdateCompanionBuilder =
    CacheWalletBalanceCompanion Function({
      Value<String> projectId,
      Value<double> balance,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CacheWalletBalanceTableFilterComposer
    extends Composer<_$AppDatabase, $CacheWalletBalanceTable> {
  $$CacheWalletBalanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheWalletBalanceTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheWalletBalanceTable> {
  $$CacheWalletBalanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheWalletBalanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheWalletBalanceTable> {
  $$CacheWalletBalanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheWalletBalanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheWalletBalanceTable,
          CacheWalletBalanceData,
          $$CacheWalletBalanceTableFilterComposer,
          $$CacheWalletBalanceTableOrderingComposer,
          $$CacheWalletBalanceTableAnnotationComposer,
          $$CacheWalletBalanceTableCreateCompanionBuilder,
          $$CacheWalletBalanceTableUpdateCompanionBuilder,
          (
            CacheWalletBalanceData,
            BaseReferences<
              _$AppDatabase,
              $CacheWalletBalanceTable,
              CacheWalletBalanceData
            >,
          ),
          CacheWalletBalanceData,
          PrefetchHooks Function()
        > {
  $$CacheWalletBalanceTableTableManager(
    _$AppDatabase db,
    $CacheWalletBalanceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheWalletBalanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheWalletBalanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheWalletBalanceTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> projectId = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheWalletBalanceCompanion(
                projectId: projectId,
                balance: balance,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String projectId,
                required double balance,
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheWalletBalanceCompanion.insert(
                projectId: projectId,
                balance: balance,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheWalletBalanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheWalletBalanceTable,
      CacheWalletBalanceData,
      $$CacheWalletBalanceTableFilterComposer,
      $$CacheWalletBalanceTableOrderingComposer,
      $$CacheWalletBalanceTableAnnotationComposer,
      $$CacheWalletBalanceTableCreateCompanionBuilder,
      $$CacheWalletBalanceTableUpdateCompanionBuilder,
      (
        CacheWalletBalanceData,
        BaseReferences<
          _$AppDatabase,
          $CacheWalletBalanceTable,
          CacheWalletBalanceData
        >,
      ),
      CacheWalletBalanceData,
      PrefetchHooks Function()
    >;
typedef $$CacheMasterMaterialsTableCreateCompanionBuilder =
    CacheMasterMaterialsCompanion Function({
      required String id,
      required String payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheMasterMaterialsTableUpdateCompanionBuilder =
    CacheMasterMaterialsCompanion Function({
      Value<String> id,
      Value<String> payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CacheMasterMaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $CacheMasterMaterialsTable> {
  $$CacheMasterMaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheMasterMaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheMasterMaterialsTable> {
  $$CacheMasterMaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheMasterMaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheMasterMaterialsTable> {
  $$CacheMasterMaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheMasterMaterialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheMasterMaterialsTable,
          CacheMasterMaterial,
          $$CacheMasterMaterialsTableFilterComposer,
          $$CacheMasterMaterialsTableOrderingComposer,
          $$CacheMasterMaterialsTableAnnotationComposer,
          $$CacheMasterMaterialsTableCreateCompanionBuilder,
          $$CacheMasterMaterialsTableUpdateCompanionBuilder,
          (
            CacheMasterMaterial,
            BaseReferences<
              _$AppDatabase,
              $CacheMasterMaterialsTable,
              CacheMasterMaterial
            >,
          ),
          CacheMasterMaterial,
          PrefetchHooks Function()
        > {
  $$CacheMasterMaterialsTableTableManager(
    _$AppDatabase db,
    $CacheMasterMaterialsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheMasterMaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheMasterMaterialsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CacheMasterMaterialsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMasterMaterialsCompanion(
                id: id,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payloadJson,
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMasterMaterialsCompanion.insert(
                id: id,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheMasterMaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheMasterMaterialsTable,
      CacheMasterMaterial,
      $$CacheMasterMaterialsTableFilterComposer,
      $$CacheMasterMaterialsTableOrderingComposer,
      $$CacheMasterMaterialsTableAnnotationComposer,
      $$CacheMasterMaterialsTableCreateCompanionBuilder,
      $$CacheMasterMaterialsTableUpdateCompanionBuilder,
      (
        CacheMasterMaterial,
        BaseReferences<
          _$AppDatabase,
          $CacheMasterMaterialsTable,
          CacheMasterMaterial
        >,
      ),
      CacheMasterMaterial,
      PrefetchHooks Function()
    >;
typedef $$CacheMaterialsTableCreateCompanionBuilder =
    CacheMaterialsCompanion Function({
      required String id,
      required String projectId,
      required String payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheMaterialsTableUpdateCompanionBuilder =
    CacheMaterialsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CacheMaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $CacheMaterialsTable> {
  $$CacheMaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheMaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheMaterialsTable> {
  $$CacheMaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheMaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheMaterialsTable> {
  $$CacheMaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheMaterialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheMaterialsTable,
          CacheMaterial,
          $$CacheMaterialsTableFilterComposer,
          $$CacheMaterialsTableOrderingComposer,
          $$CacheMaterialsTableAnnotationComposer,
          $$CacheMaterialsTableCreateCompanionBuilder,
          $$CacheMaterialsTableUpdateCompanionBuilder,
          (
            CacheMaterial,
            BaseReferences<_$AppDatabase, $CacheMaterialsTable, CacheMaterial>,
          ),
          CacheMaterial,
          PrefetchHooks Function()
        > {
  $$CacheMaterialsTableTableManager(
    _$AppDatabase db,
    $CacheMaterialsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheMaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheMaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheMaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMaterialsCompanion(
                id: id,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String payloadJson,
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMaterialsCompanion.insert(
                id: id,
                projectId: projectId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheMaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheMaterialsTable,
      CacheMaterial,
      $$CacheMaterialsTableFilterComposer,
      $$CacheMaterialsTableOrderingComposer,
      $$CacheMaterialsTableAnnotationComposer,
      $$CacheMaterialsTableCreateCompanionBuilder,
      $$CacheMaterialsTableUpdateCompanionBuilder,
      (
        CacheMaterial,
        BaseReferences<_$AppDatabase, $CacheMaterialsTable, CacheMaterial>,
      ),
      CacheMaterial,
      PrefetchHooks Function()
    >;
typedef $$CacheMaterialLedgerTableCreateCompanionBuilder =
    CacheMaterialLedgerCompanion Function({
      required String id,
      required String projectId,
      required String materialId,
      required String payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });
typedef $$CacheMaterialLedgerTableUpdateCompanionBuilder =
    CacheMaterialLedgerCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> materialId,
      Value<String> payloadJson,
      Value<String?> updatedAt,
      Value<int> rowid,
    });

class $$CacheMaterialLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $CacheMaterialLedgerTable> {
  $$CacheMaterialLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheMaterialLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheMaterialLedgerTable> {
  $$CacheMaterialLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheMaterialLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheMaterialLedgerTable> {
  $$CacheMaterialLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CacheMaterialLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheMaterialLedgerTable,
          CacheMaterialLedgerData,
          $$CacheMaterialLedgerTableFilterComposer,
          $$CacheMaterialLedgerTableOrderingComposer,
          $$CacheMaterialLedgerTableAnnotationComposer,
          $$CacheMaterialLedgerTableCreateCompanionBuilder,
          $$CacheMaterialLedgerTableUpdateCompanionBuilder,
          (
            CacheMaterialLedgerData,
            BaseReferences<
              _$AppDatabase,
              $CacheMaterialLedgerTable,
              CacheMaterialLedgerData
            >,
          ),
          CacheMaterialLedgerData,
          PrefetchHooks Function()
        > {
  $$CacheMaterialLedgerTableTableManager(
    _$AppDatabase db,
    $CacheMaterialLedgerTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheMaterialLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheMaterialLedgerTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CacheMaterialLedgerTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> materialId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMaterialLedgerCompanion(
                id: id,
                projectId: projectId,
                materialId: materialId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String materialId,
                required String payloadJson,
                Value<String?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMaterialLedgerCompanion.insert(
                id: id,
                projectId: projectId,
                materialId: materialId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheMaterialLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheMaterialLedgerTable,
      CacheMaterialLedgerData,
      $$CacheMaterialLedgerTableFilterComposer,
      $$CacheMaterialLedgerTableOrderingComposer,
      $$CacheMaterialLedgerTableAnnotationComposer,
      $$CacheMaterialLedgerTableCreateCompanionBuilder,
      $$CacheMaterialLedgerTableUpdateCompanionBuilder,
      (
        CacheMaterialLedgerData,
        BaseReferences<
          _$AppDatabase,
          $CacheMaterialLedgerTable,
          CacheMaterialLedgerData
        >,
      ),
      CacheMaterialLedgerData,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String entityType,
      required DateTime lastPullAt,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> entityType,
      Value<DateTime> lastPullAt,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => column,
  );
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<DateTime> lastPullAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                entityType: entityType,
                lastPullAt: lastPullAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required DateTime lastPullAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                entityType: entityType,
                lastPullAt: lastPullAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SyncQueuesTableTableManager get syncQueues =>
      $$SyncQueuesTableTableManager(_db, _db.syncQueues);
  $$CacheProjectsTableTableManager get cacheProjects =>
      $$CacheProjectsTableTableManager(_db, _db.cacheProjects);
  $$CacheTaskStatusesTableTableManager get cacheTaskStatuses =>
      $$CacheTaskStatusesTableTableManager(_db, _db.cacheTaskStatuses);
  $$CacheTasksTableTableManager get cacheTasks =>
      $$CacheTasksTableTableManager(_db, _db.cacheTasks);
  $$CacheTaskUpdatesTableTableManager get cacheTaskUpdates =>
      $$CacheTaskUpdatesTableTableManager(_db, _db.cacheTaskUpdates);
  $$CacheAttendanceTableTableManager get cacheAttendance =>
      $$CacheAttendanceTableTableManager(_db, _db.cacheAttendance);
  $$CacheDailyReportEntriesTableTableManager get cacheDailyReportEntries =>
      $$CacheDailyReportEntriesTableTableManager(
        _db,
        _db.cacheDailyReportEntries,
      );
  $$CacheExpenseTransactionsTableTableManager get cacheExpenseTransactions =>
      $$CacheExpenseTransactionsTableTableManager(
        _db,
        _db.cacheExpenseTransactions,
      );
  $$CacheWalletBalanceTableTableManager get cacheWalletBalance =>
      $$CacheWalletBalanceTableTableManager(_db, _db.cacheWalletBalance);
  $$CacheMasterMaterialsTableTableManager get cacheMasterMaterials =>
      $$CacheMasterMaterialsTableTableManager(_db, _db.cacheMasterMaterials);
  $$CacheMaterialsTableTableManager get cacheMaterials =>
      $$CacheMaterialsTableTableManager(_db, _db.cacheMaterials);
  $$CacheMaterialLedgerTableTableManager get cacheMaterialLedger =>
      $$CacheMaterialLedgerTableTableManager(_db, _db.cacheMaterialLedger);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
}
