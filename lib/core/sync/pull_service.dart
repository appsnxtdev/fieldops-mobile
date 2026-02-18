import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../network/api_client.dart';
import '../storage/app_database.dart';

/// Pulls data from API and merges into local cache with last-write-wins.
class PullService {
  PullService({
    AppDatabase? db,
    Dio? dio,
  })  : _db = db ?? AppDatabase(),
        _dio = dio ?? ApiClient.instance.dio;

  final AppDatabase _db;
  final Dio _dio;

  static bool _isLocalNewerOrEqual(String? localUpdatedAt, String? serverUpdatedAt) {
    if (serverUpdatedAt == null) return true;
    if (localUpdatedAt == null) return false;
    return localUpdatedAt.compareTo(serverUpdatedAt) >= 0;
  }

  Future<void> runFullPull() async {
    await _pullProjects();
    await _pullMasterMaterials();
    final projects = await _db.select(_db.cacheProjects).get();
    for (final row in projects) {
      final map = jsonDecode(row.payloadJson) as Map<String, dynamic>?;
      final projectId = map?['id'] as String?;
      if (projectId == null) continue;
      await _pullTaskStatuses(projectId);
      await _pullTasks(projectId);
      await _pullTaskUpdatesForProject(projectId);
      await _pullExpense(projectId);
      await _pullMaterials(projectId);
      await _pullMaterialLedgerForProject(projectId);
      await _pullAttendanceLastDays(projectId, 7);
      await _pullDailyReportEntriesLastDays(projectId, 7);
    }
    await _setLastPullAt('full');
  }

  Future<void> _pullProjects() async {
    final res = await _dio.get<List<dynamic>>('/api/v1/projects');
    final list = res.data ?? [];
    for (final e in list) {
      final item = e as Map<String, dynamic>;
      final id = item['id'] as String?;
      if (id == null) continue;
      final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
      final existing = await (_db.select(_db.cacheProjects)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing != null && _isLocalNewerOrEqual(existing.updatedAt, updatedAt)) continue;
      final json = jsonEncode(item);
      await _db.into(_db.cacheProjects).insert(
        CacheProjectsCompanion.insert(id: id, payloadJson: json, updatedAt: Value(updatedAt)),
        onConflict: DoUpdate((old) => CacheProjectsCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
      );
    }
  }

  Future<void> _pullMasterMaterials() async {
    final res = await _dio.get<List<dynamic>>('/api/v1/master-materials');
    final list = res.data ?? [];
    for (final e in list) {
      final item = e as Map<String, dynamic>;
      final id = item['id'] as String?;
      if (id == null) continue;
      final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
      final existing = await (_db.select(_db.cacheMasterMaterials)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing != null && _isLocalNewerOrEqual(existing.updatedAt, updatedAt)) continue;
      final json = jsonEncode(item);
      await _db.into(_db.cacheMasterMaterials).insert(
        CacheMasterMaterialsCompanion.insert(id: id, payloadJson: json, updatedAt: Value(updatedAt)),
        onConflict: DoUpdate((old) => CacheMasterMaterialsCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
      );
    }
  }

  Future<void> _pullTaskStatuses(String projectId) async {
    final res = await _dio.get<List<dynamic>>('/api/v1/tasks/$projectId/statuses');
    final list = res.data ?? [];
    for (final e in list) {
      final item = e as Map<String, dynamic>;
      final id = item['id'] as String?;
      if (id == null) continue;
      final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
      final existing = await (_db.select(_db.cacheTaskStatuses)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing != null && _isLocalNewerOrEqual(existing.updatedAt, updatedAt)) continue;
      final json = jsonEncode(item);
      await _db.into(_db.cacheTaskStatuses).insert(
        CacheTaskStatusesCompanion.insert(id: id, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAt)),
        onConflict: DoUpdate((old) => CacheTaskStatusesCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
      );
    }
  }

  Future<void> _pullTasks(String projectId) async {
    final res = await _dio.get<List<dynamic>>('/api/v1/tasks/$projectId/tasks');
    final list = res.data ?? [];
    for (final e in list) {
      final item = e as Map<String, dynamic>;
      final id = item['id'] as String?;
      if (id == null) continue;
      final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
      final existing = await (_db.select(_db.cacheTasks)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing != null && _isLocalNewerOrEqual(existing.updatedAt, updatedAt)) continue;
      final json = jsonEncode(item);
      await _db.into(_db.cacheTasks).insert(
        CacheTasksCompanion.insert(id: id, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAt)),
        onConflict: DoUpdate((old) => CacheTasksCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
      );
    }
  }

  Future<void> _pullTaskUpdatesForProject(String projectId) async {
    final taskRows = await (_db.select(_db.cacheTasks)..where((t) => t.projectId.equals(projectId))).get();
    for (final tr in taskRows) {
      final taskId = (jsonDecode(tr.payloadJson) as Map<String, dynamic>)['id'] as String?;
      if (taskId == null) continue;
      try {
        final res = await _dio.get<List<dynamic>>('/api/v1/tasks/$projectId/tasks/$taskId/updates');
        final list = res.data ?? [];
        for (final e in list) {
          final item = e as Map<String, dynamic>;
          final id = item['id'] as String?;
          if (id == null) continue;
          final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
          final existing = await (_db.select(_db.cacheTaskUpdates)..where((t) => t.id.equals(id))).getSingleOrNull();
          if (existing != null && _isLocalNewerOrEqual(existing.updatedAt, updatedAt)) continue;
          final json = jsonEncode(item);
          await _db.into(_db.cacheTaskUpdates).insert(
            CacheTaskUpdatesCompanion.insert(id: id, taskId: taskId, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAt)),
            onConflict: DoUpdate((old) => CacheTaskUpdatesCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
          );
        }
      } on DioException catch (_) {}
    }
  }

  Future<void> _pullExpense(String projectId) async {
    final res = await _dio.get<Map<String, dynamic>>('/api/v1/expense/$projectId');
    final data = res.data;
    if (data == null) return;
    final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
    final updatedAt = data['updated_at'] as String? ?? DateTime.now().toUtc().toIso8601String();
    await _db.into(_db.cacheWalletBalance).insert(
      CacheWalletBalanceCompanion.insert(projectId: projectId, balance: balance, updatedAt: Value(updatedAt)),
      onConflict: DoUpdate((old) => CacheWalletBalanceCompanion(balance: Value(balance), updatedAt: Value(updatedAt))),
    );
    final list = data['transactions'] as List<dynamic>? ?? [];
    for (final e in list) {
      final item = e as Map<String, dynamic>;
      final id = item['id'] as String?;
      if (id == null) continue;
      final updatedAtTx = item['updated_at'] as String? ?? item['created_at'] as String?;
      final existing = await (_db.select(_db.cacheExpenseTransactions)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing != null && _isLocalNewerOrEqual(existing.updatedAt, updatedAtTx)) continue;
      final json = jsonEncode(item);
      await _db.into(_db.cacheExpenseTransactions).insert(
        CacheExpenseTransactionsCompanion.insert(id: id, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAtTx)),
        onConflict: DoUpdate((old) => CacheExpenseTransactionsCompanion(payloadJson: Value(json), updatedAt: Value(updatedAtTx))),
      );
    }
  }

  Future<void> _pullMaterials(String projectId) async {
    final res = await _dio.get<List<dynamic>>('/api/v1/materials/$projectId/materials');
    final list = res.data ?? [];
    for (final e in list) {
      final item = e as Map<String, dynamic>;
      final id = item['id'] as String?;
      if (id == null) continue;
      final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
      final existing = await (_db.select(_db.cacheMaterials)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing != null && _isLocalNewerOrEqual(existing.updatedAt, updatedAt)) continue;
      final json = jsonEncode(item);
      await _db.into(_db.cacheMaterials).insert(
        CacheMaterialsCompanion.insert(id: id, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAt)),
        onConflict: DoUpdate((old) => CacheMaterialsCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
      );
    }
  }

  Future<void> _pullMaterialLedgerForProject(String projectId) async {
    final matRows = await (_db.select(_db.cacheMaterials)..where((t) => t.projectId.equals(projectId))).get();
    for (final mr in matRows) {
      final materialId = (jsonDecode(mr.payloadJson) as Map<String, dynamic>)['id'] as String?;
      if (materialId == null) continue;
      try {
        final res = await _dio.get<List<dynamic>>('/api/v1/materials/$projectId/materials/$materialId/ledger');
        final list = res.data ?? [];
        for (final e in list) {
          final item = e as Map<String, dynamic>;
          final id = item['id'] as String?;
          if (id == null) continue;
          final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
          final existing = await (_db.select(_db.cacheMaterialLedger)..where((t) => t.id.equals(id))).getSingleOrNull();
          if (existing != null && _isLocalNewerOrEqual(existing.updatedAt, updatedAt)) continue;
          final json = jsonEncode(item);
          await _db.into(_db.cacheMaterialLedger).insert(
            CacheMaterialLedgerCompanion.insert(id: id, projectId: projectId, materialId: materialId, payloadJson: json, updatedAt: Value(updatedAt)),
            onConflict: DoUpdate((old) => CacheMaterialLedgerCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
          );
        }
      } on DioException catch (_) {}
    }
  }

  Future<void> _pullAttendanceLastDays(String projectId, int days) async {
    final now = DateTime.now().toUtc();
    for (var i = 0; i < days; i++) {
      final d = now.subtract(Duration(days: i));
      final date = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      try {
        final res = await _dio.get<List<dynamic>>('/api/v1/attendance/$projectId', queryParameters: {'date': date});
        final list = res.data ?? [];
        for (final e in list) {
          final item = e as Map<String, dynamic>;
          final id = item['id'] as String?;
          if (id == null) continue;
          final updatedAt = item['updated_at'] as String? ?? item['check_in_at'] as String? ?? item['check_out_at'] as String?;
          final existing = await (_db.select(_db.cacheAttendance)..where((t) => t.id.equals(id))).getSingleOrNull();
          if (existing != null && _isLocalNewerOrEqual(existing.updatedAt, updatedAt)) continue;
          final json = jsonEncode(item);
          await _db.into(_db.cacheAttendance).insert(
            CacheAttendanceCompanion.insert(id: id, projectId: projectId, payloadJson: json, updatedAt: Value(updatedAt)),
            onConflict: DoUpdate((old) => CacheAttendanceCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
          );
        }
      } on DioException catch (_) {
        // skip single date failure
      }
    }
  }

  Future<void> _pullDailyReportEntriesLastDays(String projectId, int days) async {
    final now = DateTime.now().toUtc();
    for (var i = 0; i < days; i++) {
      final d = now.subtract(Duration(days: i));
      final reportDate = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      try {
        final res = await _dio.get<List<dynamic>>(
          '/api/v1/daily-reports/$projectId/entries',
          queryParameters: {'report_date': reportDate},
        );
        final list = res.data ?? [];
        for (final e in list) {
          final item = e as Map<String, dynamic>;
          final id = item['id'] as String?;
          if (id == null) continue;
          final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
          final existing = await (_db.select(_db.cacheDailyReportEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
          if (existing != null && _isLocalNewerOrEqual(existing.updatedAt, updatedAt)) continue;
          final json = jsonEncode(item);
          await _db.into(_db.cacheDailyReportEntries).insert(
            CacheDailyReportEntriesCompanion.insert(id: id, projectId: projectId, reportDate: reportDate, payloadJson: json, updatedAt: Value(updatedAt)),
            onConflict: DoUpdate((old) => CacheDailyReportEntriesCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
          );
        }
      } on DioException catch (_) {
        // skip single date failure
      }
    }
  }

  Future<void> _setLastPullAt(String entityType) async {
    await _db.into(_db.syncMetadata).insert(
      SyncMetadataCompanion.insert(entityType: entityType, lastPullAt: DateTime.now().toUtc()),
      onConflict: DoUpdate((old) => SyncMetadataCompanion(lastPullAt: Value(DateTime.now().toUtc()))),
    );
  }
}
