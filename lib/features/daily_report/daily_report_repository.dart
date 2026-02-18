import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/app_database.dart';

class DailyReportEntry {
  const DailyReportEntry({
    required this.id,
    required this.dailyReportId,
    required this.type,
    required this.content,
    this.sortOrder = 0,
    this.createdAt,
  });
  final String id;
  final String dailyReportId;
  final String type; // "note" | "photo"
  final String content;
  final int sortOrder;
  final String? createdAt;

  static DailyReportEntry fromJson(Map<String, dynamic> json) {
    return DailyReportEntry(
      id: json['id'] as String,
      dailyReportId: json['daily_report_id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String?,
    );
  }
}

class DailyReportRepository {
  DailyReportRepository({AppDatabase? db}) : _db = db ?? AppDatabase(), _dio = ApiClient.instance.dio;
  final AppDatabase _db;
  final Dio _dio;

  /// Returns report dates that have at least one report (most recent first), for default date.
  Future<List<String>> getRecentDates(String projectId, {int limit = 14}) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/daily-reports/recent-dates',
        queryParameters: {'project_id': projectId, 'limit': limit},
      );
      final raw = res.data;
      if (raw is List) {
        return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }
    } on DioException catch (_) {}
    return [];
  }

  /// Fetches entries from API when online (and merges into cache); falls back to cache only when offline.
  Future<List<DailyReportEntry>> getEntries(String projectId, String reportDate) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/daily-reports/$projectId/entries',
        queryParameters: {'report_date': reportDate},
      );
      final raw = res.data;
      final list = raw is List
          ? raw
          : (raw is Map && raw['data'] is List)
              ? raw['data'] as List
              : <dynamic>[];
      final entries = <DailyReportEntry>[];
      for (final e in list) {
        final item = e as Map<String, dynamic>;
        final id = item['id'] as String?;
        if (id == null) continue;
        final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
        final json = jsonEncode(item);
        await _db.into(_db.cacheDailyReportEntries).insert(
          CacheDailyReportEntriesCompanion.insert(
            id: id,
            projectId: projectId,
            reportDate: reportDate,
            payloadJson: json,
            updatedAt: Value(updatedAt),
          ),
          onConflict: DoUpdate((old) => CacheDailyReportEntriesCompanion(
            payloadJson: Value(json),
            updatedAt: Value(updatedAt),
          )),
        );
        entries.add(DailyReportEntry.fromJson(item));
      }
      entries.sort((a, b) {
        final o = a.sortOrder.compareTo(b.sortOrder);
        if (o != 0) return o;
        return (a.createdAt ?? '').compareTo(b.createdAt ?? '');
      });
      return entries;
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          (e.type == DioExceptionType.unknown && e.response == null);
      if (!isOffline) rethrow;
    }
    final rows = await (_db.select(_db.cacheDailyReportEntries)
          ..where((t) => Expression.and([t.projectId.equals(projectId), t.reportDate.equals(reportDate)])))
        .get();
    rows.sort((a, b) {
      final jA = jsonDecode(a.payloadJson) as Map<String, dynamic>;
      final jB = jsonDecode(b.payloadJson) as Map<String, dynamic>;
      return ((jA['sort_order'] as num?) ?? 0).compareTo((jB['sort_order'] as num?) ?? 0);
    });
    return rows.map((r) => DailyReportEntry.fromJson(jsonDecode(r.payloadJson) as Map<String, dynamic>)).toList();
  }

  Future<DailyReportEntry> addNote(String projectId, String reportDate, String content, {int sortOrder = 0}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/daily-reports/$projectId/entries',
      data: <String, dynamic>{
        'report_date': reportDate,
        'type': 'note',
        'content': content,
        'sort_order': sortOrder,
      },
    );
    return DailyReportEntry.fromJson(res.data!);
  }

  Future<DailyReportEntry> addPhoto(String projectId, String reportDate, String photoPath, {int sortOrder = 0}) async {
    final file = File(photoPath);
    if (!file.existsSync()) throw ArgumentError('Photo file not found: $photoPath');
    final formData = FormData.fromMap({
      'report_date': reportDate,
      'sort_order': sortOrder,
      'photo': await MultipartFile.fromFile(photoPath, filename: 'photo.jpg'),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/daily-reports/$projectId/entries/photo',
      data: formData,
    );
    return DailyReportEntry.fromJson(res.data!);
  }
}
