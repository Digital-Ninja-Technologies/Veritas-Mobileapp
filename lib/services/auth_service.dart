import '../core/models.dart';
import 'api_client.dart';
import 'token_storage.dart';

class AuthService {
  final ApiClient api;
  final TokenStore tokenStorage;

  AuthService(this.api, this.tokenStorage);

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final json = await api.post('/auth/register', auth: false, body: {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    });
    await _persistTokens(json!);
    return UserModel.fromApi(json['user'] as Map<String, dynamic>);
  }

  Future<UserModel> login({required String email, required String password}) async {
    final json = await api.post('/auth/login', auth: false, body: {
      'email': email,
      'password': password,
    });
    await _persistTokens(json!);
    return UserModel.fromApi(json['user'] as Map<String, dynamic>);
  }

  /// Attempts to exchange a stored refresh token for a fresh pair, without
  /// requiring the user to re-enter credentials. Returns false (and leaves
  /// storage untouched) if there's no stored token or it's no longer valid.
  Future<bool> silentRefresh() async {
    final refreshToken = await tokenStorage.refreshToken;
    if (refreshToken == null) return false;
    try {
      final json = await api.post('/auth/refresh', auth: false, body: {
        'refresh_token': refreshToken,
      });
      await _persistTokens(json!);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<UserModel> me({UserModel? previous}) async {
    final json = await api.get('/auth/me');
    return UserModel.fromApi(json!['data'] as Map<String, dynamic>, previous: previous);
  }

  Future<void> logout() => tokenStorage.clear();

  Future<void> _persistTokens(Map<String, dynamic> json) => tokenStorage.save(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );
}
