import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clear();
  Future<String?> readEmail();
  Future<void> writeEmail(String email);
}

abstract class TokenStorageManager {
  static final TokenStorage instance = _TokenStorageImpl();
}

class _TokenStorageImpl implements TokenStorage {
  static const _tokenKey = 'access_token';
  static const _emailKey = 'email';
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) => _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
  }

  @override
  Future<String?> readEmail() => _storage.read(key: _emailKey);

  @override
  Future<void> writeEmail(String email) => _storage.write(key: _emailKey, value: email);
}
