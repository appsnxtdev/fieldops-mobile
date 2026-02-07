import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';

/// Pending sync items. Insert when offline; worker marks synced when API succeeds.
class SyncQueueRepository {
  SyncQueueRepository({AppDatabase? db}) : _db = db ?? AppDatabase();

  final AppDatabase _db;

  Future<int> add(String kind, Map<String, dynamic> payload) {
    return _db.into(_db.syncQueues).insert(
          SyncQueuesCompanion.insert(
            kind: kind,
            payloadJson: jsonEncode(payload),
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<List<SyncQueue>> getPending() {
    return (_db.select(_db.syncQueues)
          ..where((t) => t.syncedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> markSynced(int id) {
    return (_db.update(_db.syncQueues)..where((t) => t.id.equals(id)))
        .write(SyncQueuesCompanion(syncedAt: Value(DateTime.now().toUtc())));
  }

  Future<int> pendingCount() async {
    final list = await getPending();
    return list.length;
  }

  Stream<int> watchPendingCount() {
    return (_db.select(_db.syncQueues)
          ..where((t) => t.syncedAt.isNull()))
        .watch()
        .map((list) => list.length);
  }
}
