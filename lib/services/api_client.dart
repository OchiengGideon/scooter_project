// lib/services/api_client.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiResponse {
  final dynamic data;
  final int statusCode;
  final String? message;

  ApiResponse({
    required this.data,
    required this.statusCode,
    this.message,
  });
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiClient {
  static const String baseUrl = 'https://api.yourscooterapp.com'; // Replace with your API URL
  static const Duration timeout = Duration(seconds: 30);

  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  String? _authToken;

  // Add authentication token to headers
  void setAuthToken(String token) {
    _authToken = token;
    _headers['Authorization'] = 'Bearer $token';
  }

  // Remove authentication token
  void clearAuthToken() {
    _authToken = null;
    _headers.remove('Authorization');
  }

  // ---------- Public HTTP helpers with retry ----------
  Future<ApiResponse> get(String endpoint, {Map<String, String>? queryParams}) {
    return _withRetry(() => _get(endpoint, queryParams: queryParams));
  }

  Future<ApiResponse> post(String endpoint, dynamic data) {
    return _withRetry(() => _post(endpoint, data));
  }

  Future<ApiResponse> patch(String endpoint, dynamic data) {
    return _withRetry(() => _patch(endpoint, data));
  }

  Future<ApiResponse> delete(String endpoint) {
    return _withRetry(() => _delete(endpoint));
  }

  // ---------- Internal implementations ----------
  Future<ApiResponse> _get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

      if (kDebugMode) {
        debugPrint('API GET: $uri');
      }

      final response = await http.get(uri, headers: _headers).timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 0);
    } on http.ClientException {
      throw ApiException('Server connection failed', 0);
    } on TimeoutException {
      throw ApiException('Request timeout', 0);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  Future<ApiResponse> _post(String endpoint, dynamic data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      if (kDebugMode) {
        debugPrint('API POST: $uri');
        debugPrint('Request data: $data');
      }

      final response = await http
          .post(
        uri,
        headers: _headers,
        body: json.encode(data),
      )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection', 0);
    } on http.ClientException {
      throw ApiException('Server connection failed', 0);
    } on TimeoutException {
      throw ApiException('Request timeout', 0);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  Future<ApiResponse> _patch(String endpoint, dynamic data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      if (kDebugMode) {
        debugPrint('API PATCH: $uri');
        debugPrint('Request data: $data');
      }

      final response = await http
          .patch(
        uri,
        headers: _headers,
        body: json.encode(data),
      )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  Future<ApiResponse> _delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      if (kDebugMode) {
        debugPrint('API DELETE: $uri');
      }

      final response = await http.delete(uri, headers: _headers).timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  // ---------- Retry wrapper ----------
  Future<T> _withRetry<T>(Future<T> Function() action,
      {int maxAttempts = 3, Duration initialDelay = const Duration(milliseconds: 250)}) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      attempt++;
      try {
        return await action();
      } catch (e) {
        // For ApiException with 5xx maybe retry; for network errors retry; else rethrow
        if (attempt >= maxAttempts) rethrow;
        if (kDebugMode) debugPrint('Request failed, attempt $attempt: $e — retrying in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }

  // Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    if (kDebugMode) {
      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');
    }

    final statusCode = response.statusCode;
    dynamic responseData;

    try {
      responseData = json.decode(response.body);
    } catch (e) {
      responseData = {'message': response.body};
    }

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse(
        data: responseData,
        statusCode: statusCode,
        message: responseData is Map ? responseData['message'] as String? : null,
      );
    } else {
      final errorMessage = (responseData is Map)
          ? (responseData['message'] ?? responseData['error'] ?? 'HTTP $statusCode')
          : 'HTTP $statusCode';
      throw ApiException(errorMessage.toString(), statusCode);
    }
  }
}
