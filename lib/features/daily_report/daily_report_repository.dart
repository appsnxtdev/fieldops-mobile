import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

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
  DailyReportRepository() : _dio = ApiClient.instance.dio;
  final Dio _dio;

  Future<List<DailyReportEntry>> getEntries(String projectId, String reportDate) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/v1/daily-reports/$projectId/entries',
      queryParameters: {'report_date': reportDate},
    );
    final list = res.data ?? [];
    return list.map((e) => DailyReportEntry.fromJson(e as Map<String, dynamic>)).toList();
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
