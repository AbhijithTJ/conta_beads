import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'session_service.dart';
import 'language_id_service.dart';

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
  final Map<String, dynamic>? responseBody;
  const ApiException({required this.message, this.statusCode, this.responseBody});

  @override
  String toString() => 'ApiException($statusCode): $message (Body: $responseBody)';
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
      'X-Language-ID': languageIdService.languageId.toString(),
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

    throw ApiException(
      message: _extractErrorMessage(body, response.statusCode),
      statusCode: response.statusCode,
      responseBody: body,
    );
  }

  /// Extracts a human-readable message from the backend error body.
  ///
  /// Handles these shapes:
  ///   { "error": { "message": "...", "details": { "field": ["msg"] } } }
  ///   { "message": "..." }
  ///   { "error": "plain string" }
  String _extractErrorMessage(Map<String, dynamic> body, int statusCode) {
    final error = body['error'];

    if (error is Map<String, dynamic>) {
      // Check for field-level validation details first.
      final details = error['details'];
      if (details is Map<String, dynamic> && details.isNotEmpty) {
        // Collect all field messages into one readable string.
        final messages = <String>[];
        details.forEach((field, value) {
          if (value is List && value.isNotEmpty) {
            messages.add(value.first.toString());
          } else if (value is String) {
            messages.add(value);
          }
        });
        if (messages.isNotEmpty) return messages.join('\n');
      }
      // Fall back to the top-level message inside the error object.
      final msg = error['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }

    if (error is String && error.isNotEmpty) return error;

    final msg = body['message'];
    if (msg is String && msg.isNotEmpty) return msg;

    return 'Something went wrong ($statusCode).';
  }
}
