import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';

const _cacheKey = 'cached_tenant_me';

class Tenant {
  const Tenant({required this.id, this.name});
  final String id;
  final String? name;

  static Tenant fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String?,
    );
  }
}

class TenantRepository {
  TenantRepository() : _dio = ApiClient.instance.dio;
  final Dio _dio;

  Future<Tenant> getMyTenant() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/tenants/me');
      final data = res.data;
      if (data != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(data));
        return Tenant.fromJson(data);
      }
    } on DioException catch (e) {
      final isNetwork = e.response == null ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown;
      if (isNetwork) {
        final prefs = await SharedPreferences.getInstance();
        final cached = prefs.getString(_cacheKey);
        if (cached != null) {
          final data = jsonDecode(cached) as Map<String, dynamic>?;
          if (data != null) return Tenant.fromJson(data);
        }
      }
      rethrow;
    }
    throw StateError('No tenant data');
  }
}
