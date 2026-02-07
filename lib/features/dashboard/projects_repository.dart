import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

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
  ProjectsRepository() : _dio = ApiClient.instance.dio;
  final Dio _dio;

  Future<List<Project>> getProjects() async {
    final res = await _dio.get<List<dynamic>>('/api/v1/projects');
    final list = res.data ?? [];
    return list.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Project?> getProject(String projectId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/projects/$projectId');
      return Project.fromJson(res.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Current user's role on this project: admin | member | viewer.
  Future<String?> getMyProjectAccess(String projectId) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/projects/$projectId/my-access');
      final data = res.data;
      if (data is! Map<String, dynamic>) return null;
      final role = data['role'];
      return role is String ? role : role?.toString();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}

