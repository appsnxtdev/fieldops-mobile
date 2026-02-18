import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';

const _cacheKey = 'cached_user_me';

class UserProfile {
  const UserProfile({required this.id, this.email, this.fullName, this.avatarUrl});
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;

  static UserProfile fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class UserRepository {
  UserRepository() : _dio = ApiClient.instance.dio;
  final Dio _dio;

  Future<UserProfile> getMe() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/users/me');
      final data = res.data;
      if (data != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(data));
        return UserProfile.fromJson(data);
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
          if (data != null) return UserProfile.fromJson(data);
        }
      }
      rethrow;
    }
    throw StateError('No user data');
  }
}
