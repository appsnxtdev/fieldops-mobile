import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class SyncQueues extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

/// Local cache: id + payload json + updated_at for last-write-wins merge.
class CacheProjects extends Table {
  TextColumn get id => text()();
  TextColumn get payloadJson => text()();
  TextColumn get updatedAt => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class CacheTaskStatuses extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get updatedAt => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class CacheTasks extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get updatedAt => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class CacheTaskUpdates extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get projectId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get updatedAt => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class CacheAttendance extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get updatedAt => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class CacheDailyReportEntries extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get reportDate => text()();
  TextColumn get payloadJson => text()();
  TextColumn get updatedAt => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class CacheExpenseTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get updatedAt => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class CacheWalletBalance extends Table {
  TextColumn get projectId => text()();
  RealColumn get balance => real()();
  TextColumn get updatedAt => text().nullable()();
  @override
  Set<Column> get primaryKey => {projectId};
}

class CacheMasterMaterials extends Table {
  TextColumn get id => text()();
  TextColumn get payloadJson => text()();
  TextColumn get updatedAt => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class CacheMaterials extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get updatedAt => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class CacheMaterialLedger extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get materialId => text()();
  TextColumn get payloadJson => text()();
  TextColumn get updatedAt => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class SyncMetadata extends Table {
  TextColumn get entityType => text()();
  DateTimeColumn get lastPullAt => dateTime()();
  @override
  Set<Column> get primaryKey => {entityType};
}

@DriftDatabase(
  tables: [
    SyncQueues,
    CacheProjects,
    CacheTaskStatuses,
    CacheTasks,
    CacheTaskUpdates,
    CacheAttendance,
    CacheDailyReportEntries,
    CacheExpenseTransactions,
    CacheWalletBalance,
    CacheMasterMaterials,
    CacheMaterials,
    CacheMaterialLedger,
    SyncMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());
  static final AppDatabase instance = AppDatabase._();
  factory AppDatabase() => instance;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'fieldops.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.createTable(cacheProjects);
            await migrator.createTable(cacheTaskStatuses);
            await migrator.createTable(cacheTasks);
            await migrator.createTable(cacheTaskUpdates);
            await migrator.createTable(cacheAttendance);
            await migrator.createTable(cacheDailyReportEntries);
            await migrator.createTable(cacheExpenseTransactions);
            await migrator.createTable(cacheWalletBalance);
            await migrator.createTable(cacheMasterMaterials);
            await migrator.createTable(cacheMaterials);
            await migrator.createTable(cacheMaterialLedger);
            await migrator.createTable(syncMetadata);
          }
        },
      );
}
