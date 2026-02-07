import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../storage/secure_token_storage.dart';

/// Singleton Dio-based client for FieldOps API. Bearer token + 401 → logout.
class ApiClient {
  ApiClient._() {
    _dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl, connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 15)));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        if (err.response?.statusCode == 401) {
          await _tokenStorage.delete();
          try {
            await Supabase.instance.client.auth.signOut();
          } catch (_) {}
          _onUnauthorized?.call();
        }
        handler.next(err);
      },
    ));
  }

  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  static void setUnauthorizedCallback(void Function() callback) {
    _onUnauthorized = callback;
  }

  static void Function()? _onUnauthorized;

  final SecureTokenStorage _tokenStorage = SecureTokenStorage();
  late final Dio _dio;

  Dio get dio => _dio;
}
