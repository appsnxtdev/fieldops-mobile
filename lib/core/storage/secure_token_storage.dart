import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _keyAccessToken = 'access_token';
const _keyRefreshToken = 'refresh_token';
const _keyUserEmail = 'user_email';

/// Persists Supabase access + refresh token and optional user email for API auth and offline login.
class SecureTokenStorage {
  SecureTokenStorage() : _storage = const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  final FlutterSecureStorage _storage;

  Future<void> write(String token) => _storage.write(key: _keyAccessToken, value: token);
  Future<String?> read() => _storage.read(key: _keyAccessToken);

  Future<void> writeRefreshToken(String? value) async {
    if (value != null) {
      await _storage.write(key: _keyRefreshToken, value: value);
    } else {
      await _storage.delete(key: _keyRefreshToken);
    }
  }
  Future<String?> readRefreshToken() => _storage.read(key: _keyRefreshToken);

  Future<void> writeUserEmail(String? value) async {
    if (value != null) {
      await _storage.write(key: _keyUserEmail, value: value);
    } else {
      await _storage.delete(key: _keyUserEmail);
    }
  }
  Future<String?> readUserEmail() => _storage.read(key: _keyUserEmail);

  /// True if we have a session that can be used for offline login (access or refresh token).
  Future<bool> hasStoredSession() async {
    final access = await read();
    if (access != null && access.isNotEmpty) return true;
    final refresh = await readRefreshToken();
    return refresh != null && refresh.isNotEmpty;
  }

  Future<void> delete() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserEmail);
  }
}
