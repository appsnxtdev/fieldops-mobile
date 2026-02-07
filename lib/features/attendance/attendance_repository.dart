import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.date,
    this.checkInAt,
    this.checkOutAt,
    this.checkInSelfiePath,
    this.checkOutSelfiePath,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });
  final String id;
  final String projectId;
  final String userId;
  final String date;
  final String? checkInAt;
  final String? checkOutAt;
  final String? checkInSelfiePath;
  final String? checkOutSelfiePath;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;

  static AttendanceRecord fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      userId: json['user_id'] as String,
      date: json['date'] as String,
      checkInAt: json['check_in_at'] as String?,
      checkOutAt: json['check_out_at'] as String?,
      checkInSelfiePath: json['check_in_selfie_path'] as String?,
      checkOutSelfiePath: json['check_out_selfie_path'] as String?,
      checkInLat: (json['check_in_lat'] as num?)?.toDouble(),
      checkInLng: (json['check_in_lng'] as num?)?.toDouble(),
      checkOutLat: (json['check_out_lat'] as num?)?.toDouble(),
      checkOutLng: (json['check_out_lng'] as num?)?.toDouble(),
    );
  }
}

class AttendanceRepository {
  AttendanceRepository() : _dio = ApiClient.instance.dio;
  final Dio _dio;

  Future<AttendanceRecord> checkIn(
    String projectId,
    String date,
    double lat,
    double lng,
    String selfiePath,
  ) async {
    final file = File(selfiePath);
    final formData = FormData.fromMap({
      'date': date,
      'lat': lat,
      'lng': lng,
      'selfie': await MultipartFile.fromFile(
        selfiePath,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/attendance/$projectId/check-in',
      data: formData,
    );
    return AttendanceRecord.fromJson(res.data!);
  }

  Future<AttendanceRecord> checkOut(
    String projectId,
    String date,
    double lat,
    double lng,
    String selfiePath,
  ) async {
    final file = File(selfiePath);
    final formData = FormData.fromMap({
      'date': date,
      'lat': lat,
      'lng': lng,
      'selfie': await MultipartFile.fromFile(
        selfiePath,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/v1/attendance/$projectId/check-out',
      data: formData,
    );
    return AttendanceRecord.fromJson(res.data!);
  }

  Future<List<AttendanceRecord>> listAttendance(String projectId, String date) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/v1/attendance/$projectId',
      queryParameters: {'date': date},
    );
    final list = res.data ?? [];
    return list.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>)).toList();
  }
}
