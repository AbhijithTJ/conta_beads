import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'session_service.dart';

// ── Response wrapper ──────────────────────────────────────────────────────────

class ApiResponse<T> {
  final T data;
  final int statusCode;
  const ApiResponse({required this.data, required this.statusCode});
}

// ── Exception ─────────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// ── Client ────────────────────────────────────────────────────────────────────

/// Low-level HTTP client.
///
/// - Token is read from [SessionService] (in-memory, zero disk I/O per call).
/// - All errors are normalised into [ApiException].
/// - Timeouts are enforced via [AppConfig.connectTimeout].
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // Reuse a single http.Client for connection pooling.
  final http.Client _client = http.Client();

  // ── Headers ──────────────────────────────────────────────────────────────────
  Map<String, String> _headers({bool auth = true}) {
    final token = auth ? SessionService.instance.token : null;
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      if (token != null && token.isNotEmpty)
        HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse('${AppConfig.baseUrl}$path');
    return query != null ? base.replace(queryParameters: query) : base;
  }

  // ── POST ──────────────────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    return _execute(() => _client
        .post(
          _uri(path),
          headers: _headers(auth: auth),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(AppConfig.connectTimeout));
  }

  // ── GET ───────────────────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) async {
    return _execute(() => _client
        .get(_uri(path, query), headers: _headers(auth: auth))
        .timeout(AppConfig.connectTimeout));
  }

  // ── PUT ───────────────────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    return _execute(() => _client
        .put(
          _uri(path),
          headers: _headers(auth: auth),
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(AppConfig.connectTimeout));
  }

  // ── DELETE ────────────────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> delete(
    String path, {
    bool auth = true,
  }) async {
    return _execute(() => _client
        .delete(_uri(path), headers: _headers(auth: auth))
        .timeout(AppConfig.connectTimeout));
  }

  // ── Shared executor ───────────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> _execute(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call();
      return _handleResponse(response);
    } on SocketException {
      throw const ApiException(message: 'No internet connection.');
    } on TimeoutException {
      throw const ApiException(message: 'Request timed out. Please try again.');
    } on HttpException {
      throw const ApiException(message: 'Network error. Please try again.');
    } on FormatException {
      throw const ApiException(message: 'Unexpected response format.');
    }
  }

  // ── Response handler ──────────────────────────────────────────────────────────
  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        message: 'Could not parse server response.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(data: body, statusCode: response.statusCode);
    }

    final msg = body['message'] as String? ??
        body['error'] as String? ??
        'Something went wrong (${response.statusCode}).';
    throw ApiException(message: msg, statusCode: response.statusCode);
  }
}
