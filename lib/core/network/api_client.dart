import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../api_constants.dart';

class ApiException implements Exception {
  ApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiClient {
  ApiClient({required http.Client client, required this.baseUrl})
    : _client = client;

  final http.Client _client;
  final String baseUrl;

  Future<dynamic> get(
    String path, {
    String? token,
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final response = await _client.get(uri, headers: _headers(token));
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    String? token,
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final response = await _client.post(
      uri,
      headers: _headers(token),
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath').replace(
      queryParameters: queryParameters?.isEmpty == true
          ? null
          : queryParameters,
    );
  }

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    }

    String message = 'Unknown API error';
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] is String) {
          message = decoded['message'] as String;
        } else {
          message = response.body;
        }
      } catch (_) {
        message = response.body;
      }
    }

    throw ApiException(statusCode: response.statusCode, message: message);
  }
}

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ref.watch(httpClientProvider);
  return ApiClient(client: client, baseUrl: ApiConstants.baseUrl);
});
