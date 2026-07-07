import 'dart:developer';

import '../core/models.dart';
import 'api_client.dart';
import 'token_storage.dart';

class PublicProfile {
  final String id;
  final String fullName;
  PublicProfile({required this.id, required this.fullName});
}

class AuthService {
  final ApiClient api;
  final TokenStore tokenStorage;

  // In-memory only — resolved names for escrow counterparties. Repopulated
  // each app session; not worth persisting since it's just a display cache.
  final Map<String, String> _nameCache = {};

  AuthService(this.api, this.tokenStorage);

  /// Resolves another user's display name via GET /users/:id. Falls back to
  /// a generic label if the lookup fails rather than throwing, since this is
  /// only ever used for display purposes (e.g. an escrow list row).
  Future<String> publicNameFor(String userId) async {
    final cached = _nameCache[userId];
    if (cached != null) return cached;
    try {
      final json = await api.get('/users/$userId');
      final name =
          (json?['data'] as Map<String, dynamic>?)?['full_name'] as String?;
      final resolved = (name == null || name.isEmpty) ? 'Veritas user' : name;
      _nameCache[userId] = resolved;
      return resolved;
    } catch (_) {
      return 'Veritas user';
    }
  }

  /// Checks whether an email belongs to a registered Veritas account —
  /// lets a client validate a prospective freelancer *before* submitting a
  /// project, instead of only finding out when creation is rejected.
  /// Returns null if no account is found; rethrows on any other failure
  /// (e.g. network error) so the caller can distinguish "not found" from
  /// "couldn't check right now".
  Future<PublicProfile?> lookupByEmail(String email) async {
    try {
      final json = await api
          .get('/users/by-email?email=${Uri.encodeQueryComponent(email)}');
      log("res:${json}");
      final data = json?['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return PublicProfile(
          id: data['id'] as String, fullName: data['full_name'] as String);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

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

  Future<UserModel> login(
      {required String email, required String password}) async {
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
    return UserModel.fromApi(json!['data'] as Map<String, dynamic>,
        previous: previous);
  }

  Future<void> logout() => tokenStorage.clear();

  Future<void> _persistTokens(Map<String, dynamic> json) => tokenStorage.save(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );
}
