import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App configuration from .env (loaded at startup). Fallback to compile-time env if needed.
class AppConfig {
  AppConfig._();

  /// API base URL. On Android emulator, localhost/127.0.0.1 is rewritten to 10.0.2.2 (host machine).
  static String get apiBaseUrl {
    final raw = dotenv.env['API_BASE_URL']?.trim().isNotEmpty == true
        ? dotenv.env['API_BASE_URL']!.trim()
        : const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
    if (Platform.isAndroid && (raw.contains('localhost') || raw.contains('127.0.0.1'))) {
      return raw
          .replaceFirst(RegExp(r'localhost'), '10.0.2.2')
          .replaceFirst(RegExp(r'127\.0\.0\.1'), '10.0.2.2');
    }
    return raw;
  }

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL']?.trim() ?? const String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
}
