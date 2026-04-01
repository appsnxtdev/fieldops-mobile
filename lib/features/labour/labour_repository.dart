import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:fieldops_mobile/core/network/api_client.dart';
import 'package:fieldops_mobile/core/storage/app_database.dart';
import 'package:fieldops_mobile/core/storage/sync_queue_repository.dart';
import 'package:fieldops_mobile/features/labour/labour_type.dart';
import 'package:fieldops_mobile/features/labour/labour_daily_entry.dart';

class LabourRepository {
  final _apiClient = ApiClient.instance;
  final _db = AppDatabase.instance;
  final _syncRepo = SyncQueueRepository();

  /// Fetch all labour types for the tenant
  /// Supports offline mode with cache fallback
  Future<List<LabourType>> getLabourTypes() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/labour-types');
      if (response.data is List) {
        final types = <LabourType>[];
        for (var json in response.data as List) {
          try {
            types.add(LabourType.fromJson(json as Map<String, dynamic>));
          } catch (e) {
            print('Error parsing labour type: $e');
            print('JSON: $json');
          }
        }

        // Cache the results
        await _cacheLabourTypes(types);

        return types;
      }
      return [];
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        // Offline - return from cache
        return await _getLabourTypesFromCache();
      }
      rethrow;
    } catch (e) {
      print('Error in getLabourTypes: $e');
      // Try cache on any error
      return await _getLabourTypesFromCache();
    }
  }

  /// Fetch labour entries for a specific project and date
  /// Supports offline mode with cache fallback
  Future<List<LabourDailyEntry>> getLabourDaily({
    required String projectId,
    required String date, // YYYY-MM-DD format
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/labour/daily',
        queryParameters: {
          'project_id': projectId,
          'date': date,
        },
      );

      if (response.data != null && response.data['entries'] is List) {
        final entries = <LabourDailyEntry>[];
        for (var json in response.data['entries'] as List) {
          try {
            entries.add(LabourDailyEntry.fromJson(json as Map<String, dynamic>));
          } catch (e) {
            print('Error parsing labour daily entry: $e');
            print('JSON: $json');
          }
        }

        // Cache the results
        await _cacheLabourDaily(projectId, date, entries);

        return entries;
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || _isNetworkError(e)) {
        // No entries for this date or offline - check cache
        return await _getLabourDailyFromCache(projectId, date);
      }
      rethrow;
    }
  }

  /// Create or update labour entries for a specific project and date
  /// This replaces ALL entries for the given date
  /// Supports offline mode with sync queue
  Future<List<LabourDailyEntry>> upsertLabourDaily({
    required String projectId,
    required String date, // YYYY-MM-DD format
    required List<Map<String, dynamic>> entries, // [{labour_type_id, count}]
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/labour/daily',
        queryParameters: {'project_id': projectId},
        data: {
          'date': date,
          'entries': entries,
        },
      );

      if (response.data != null && response.data['entries'] is List) {
        final resultEntries = (response.data['entries'] as List)
            .map((json) => LabourDailyEntry.fromJson(json))
            .toList();

        // Cache the results
        await _cacheLabourDaily(projectId, date, resultEntries);

        return resultEntries;
      }
      return [];
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        // Offline - queue for sync and update cache optimistically
        await _syncRepo.add('labour_daily_upsert', {
          'project_id': projectId,
          'date': date,
          'entries': entries,
        });

        // Calculate optimistic entries from labour types cache
        final optimisticEntries = await _calculateOptimisticEntries(entries);
        await _cacheLabourDaily(projectId, date, optimisticEntries);

        return optimisticEntries;
      }
      rethrow;
    }
  }

  // Cache labour types
  Future<void> _cacheLabourTypes(List<LabourType> types) async {
    final now = DateTime.now().toIso8601String();
    for (final type in types) {
      await _db.into(_db.cacheLabourTypes).insertOnConflictUpdate(
            CacheLabourTypesCompanion.insert(
              id: type.id,
              payloadJson: jsonEncode(type.toJson()),
              updatedAt: Value(now),
            ),
          );
    }
  }

  // Get labour types from cache
  Future<List<LabourType>> _getLabourTypesFromCache() async {
    final rows = await _db.select(_db.cacheLabourTypes).get();
    return rows
        .map((row) => LabourType.fromJson(jsonDecode(row.payloadJson)))
        .toList();
  }

  // Cache labour daily entries
  Future<void> _cacheLabourDaily(
    String projectId,
    String date,
    List<LabourDailyEntry> entries,
  ) async {
    final now = DateTime.now().toIso8601String();
    final payload = {
      'project_id': projectId,
      'date': date,
      'entries': entries.map((e) => e.toJson()).toList(),
    };

    await _db.into(_db.cacheLabourDaily).insertOnConflictUpdate(
          CacheLabourDailyCompanion.insert(
            projectId: projectId,
            date: date,
            payloadJson: jsonEncode(payload),
            updatedAt: Value(now),
          ),
        );
  }

  // Get labour daily from cache
  Future<List<LabourDailyEntry>> _getLabourDailyFromCache(
    String projectId,
    String date,
  ) async {
    final row = await (_db.select(_db.cacheLabourDaily)
          ..where((t) => t.projectId.equals(projectId) & t.date.equals(date)))
        .getSingleOrNull();

    if (row == null) return [];

    final payload = jsonDecode(row.payloadJson);
    if (payload['entries'] is List) {
      return (payload['entries'] as List)
          .map((json) => LabourDailyEntry.fromJson(json))
          .toList();
    }
    return [];
  }

  // Calculate optimistic entries for offline mode
  Future<List<LabourDailyEntry>> _calculateOptimisticEntries(
    List<Map<String, dynamic>> entries,
  ) async {
    final labourTypes = await _getLabourTypesFromCache();
    final typeMap = {for (var t in labourTypes) t.id: t};

    return entries.map((e) {
      final typeId = e['labour_type_id']?.toString() ?? '';

      // Parse count safely
      int count = 0;
      final countValue = e['count'];
      if (countValue is int) {
        count = countValue;
      } else if (countValue is String) {
        count = int.tryParse(countValue) ?? 0;
      } else if (countValue is num) {
        count = countValue.toInt();
      }

      final type = typeMap[typeId];

      return LabourDailyEntry(
        labourTypeId: typeId,
        labourTypeName: type?.name ?? 'Unknown',
        ratePerDay: type?.ratePerDay ?? 0.0,
        count: count,
        amount: count * (type?.ratePerDay ?? 0.0),
      );
    }).toList();
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown;
  }
}
