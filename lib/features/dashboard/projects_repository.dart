import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/app_database.dart';

class Project {
  const Project({
    required this.id,
    required this.tenantId,
    required this.name,
    this.timezone = 'Asia/Kolkata',
    this.lat,
    this.lng,
    this.location,
    this.address,
    this.createdAt,
    this.updatedAt,
  });
  final String id;
  final String tenantId;
  final String name;
  final String timezone;
  final double? lat;
  final double? lng;
  final String? location;
  final String? address;
  final String? createdAt;
  final String? updatedAt;

  /// Display location: location string, then address, then coordinates as fallback.
  String? get displayLocation {
    if (location != null && location!.trim().isNotEmpty) return location;
    if (address != null && address!.trim().isNotEmpty) return address;
    if (lat != null && lng != null) return '${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}';
    return null;
  }

  static Project fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      tenantId: json['tenant_id'] as String,
      name: json['name'] as String,
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      location: json['location'] as String?,
      address: json['address'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class ProjectsRepository {
  ProjectsRepository({AppDatabase? db}) : _db = db ?? AppDatabase(), _dio = ApiClient.instance.dio;
  final AppDatabase _db;
  final Dio _dio;

  /// Fetches projects from API when online (and merges into cache); falls back to cache only on network errors.
  Future<List<Project>> getProjects() async {
    try {
      final res = await _dio.get<List<dynamic>>('/api/v1/projects');
      final list = res.data ?? [];
      final projects = <Project>[];
      for (final e in list) {
        final item = e as Map<String, dynamic>;
        final id = item['id'] as String?;
        if (id == null) continue;
        final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
        final json = jsonEncode(item);
        await _db.into(_db.cacheProjects).insert(
          CacheProjectsCompanion.insert(id: id, payloadJson: json, updatedAt: Value(updatedAt)),
          onConflict: DoUpdate((old) => CacheProjectsCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
        );
        projects.add(Project.fromJson(item));
      }
      return projects;
    } on DioException catch (e) {
      final isNetwork = e.response == null ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown;
      if (!isNetwork) rethrow;
    }
    try {
      final rows = await _db.select(_db.cacheProjects).get();
      return rows.map((r) {
        final m = jsonDecode(r.payloadJson) as Map<String, dynamic>;
        return Project.fromJson(m);
      }).toList();
    } on Object {
      return [];
    }
  }

  Future<Project?> getProject(String projectId) async {
    var row = await (_db.select(_db.cacheProjects)..where((t) => t.id.equals(projectId))).getSingleOrNull();
    if (row == null) {
      try {
        final res = await _dio.get<Map<String, dynamic>>('/api/v1/projects/$projectId');
        final item = res.data;
        if (item is! Map<String, dynamic>) return null;
        final id = item['id'] as String?;
        if (id == null) return null;
        final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
        final json = jsonEncode(item);
        await _db.into(_db.cacheProjects).insert(
          CacheProjectsCompanion.insert(id: id, payloadJson: json, updatedAt: Value(updatedAt)),
          onConflict: DoUpdate((old) => CacheProjectsCompanion(payloadJson: Value(json), updatedAt: Value(updatedAt))),
        );
        return Project.fromJson(item);
      } on DioException {
        return null;
      }
    }
    return Project.fromJson(jsonDecode(row.payloadJson) as Map<String, dynamic>);
  }

  /// Current user's role on this project: admin | member | viewer. Returns null when offline or error.
  Future<String?> getMyProjectAccess(String projectId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/projects/$projectId/my-access');
      final data = res.data;
      if (data is! Map<String, dynamic>) return null;
      final role = data['role'];
      return role is String ? role : role?.toString();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) return null;
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) return null;
      return null;
    }
  }
}

