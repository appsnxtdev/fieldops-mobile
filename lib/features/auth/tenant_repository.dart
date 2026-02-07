import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

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
    final res = await _dio.get<Map<String, dynamic>>('/api/v1/tenants/me');
    return Tenant.fromJson(res.data!);
  }
}
