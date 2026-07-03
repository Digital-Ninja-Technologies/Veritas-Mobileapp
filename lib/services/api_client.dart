import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'token_storage.dart';

/// Thrown for any non-2xx response; [message] is the backend's `{"error": ...}`
/// text when present, otherwise a generic fallback.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Thin JSON HTTP client for the Veritas API. Attaches the stored access
/// token to authenticated requests and transparently retries once via the
/// refresh-token flow on a 401, so callers don't need to handle expiry.
class ApiClient {
  final TokenStore tokenStorage;
  ApiClient(this.tokenStorage);

  Future<Map<String, dynamic>?> get(String path, {bool auth = true}) =>
      _send('GET', path, auth: auth);

  Future<Map<String, dynamic>?> post(String path, {Map<String, dynamic>? body, bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);

  Future<Map<String, dynamic>?> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
    bool isRetry = false,
  }) async {
    final uri = Uri.parse('$kApiBaseUrl$path');
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await tokenStorage.accessToken;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    final encodedBody = body != null ? jsonEncode(body) : null;
    final http.Response resp;
    switch (method) {
      case 'GET':
        resp = await http.get(uri, headers: headers);
        break;
      case 'POST':
        resp = await http.post(uri, headers: headers, body: encodedBody);
        break;
      default:
        throw ApiException('unsupported HTTP method: $method');
    }

    if (resp.statusCode == 401 && auth && !isRetry) {
      if (await _refreshTokens()) {
        return _send(method, path, body: body, auth: auth, isRetry: true);
      }
    }

    Map<String, dynamic>? json;
    if (resp.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic>) json = decoded;
      } catch (_) {
        // non-JSON body — fall through, json stays null
      }
    }

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return json;
    }
    final message = json?['error']?.toString() ?? 'Request failed (${resp.statusCode})';
    throw ApiException(message, statusCode: resp.statusCode);
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = await tokenStorage.refreshToken;
    if (refreshToken == null) return false;
    try {
      final uri = Uri.parse('$kApiBaseUrl/auth/refresh');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (resp.statusCode != 200) return false;
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      await tokenStorage.save(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
