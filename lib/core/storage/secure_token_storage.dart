import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _keyAccessToken = 'access_token';

/// Persists Supabase access token for API Bearer auth.
class SecureTokenStorage {
  SecureTokenStorage() : _storage = const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  final FlutterSecureStorage _storage;

  Future<void> write(String token) => _storage.write(key: _keyAccessToken, value: token);

  Future<String?> read() => _storage.read(key: _keyAccessToken);

  Future<void> delete() => _storage.delete(key: _keyAccessToken);
}
