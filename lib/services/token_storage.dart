import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// What ApiClient/AuthService need from a token store — kept abstract so
/// tests (and the verification script under tool/) can swap in an in-memory
/// fake instead of the real platform keychain/keystore.
abstract class TokenStore {
  Future<void> save({required String accessToken, required String refreshToken});
  Future<String?> get accessToken;
  Future<String?> get refreshToken;
  Future<void> saveUser(String userJson);
  Future<String?> get user;
  Future<void> clear();
}

/// Persists the access/refresh token pair in the platform keychain/keystore
/// — never in plain SharedPreferences, since these are session credentials.
class TokenStorage implements TokenStore {
  static const _accessKey = 'veritas_access_token';
  static const _refreshKey = 'veritas_refresh_token';
  static const _userKey = 'veritas_user';

  final _storage = const FlutterSecureStorage();

  @override
  Future<void> save({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  @override
  Future<String?> get accessToken => _storage.read(key: _accessKey);
  @override
  Future<String?> get refreshToken => _storage.read(key: _refreshKey);
  
  @override
  Future<void> saveUser(String userJson) async => await _storage.write(key: _userKey, value: userJson);
  @override
  Future<String?> get user => _storage.read(key: _userKey);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userKey);
  }
}
