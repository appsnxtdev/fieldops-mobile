import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

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
    final res = await _dio.get<Map<String, dynamic>>('/api/v1/users/me');
    return UserProfile.fromJson(res.data!);
  }
}
