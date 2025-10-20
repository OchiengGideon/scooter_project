// lib/services/api_client.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

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

  // Add authentication token to headers
  void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  // Remove authentication token
  void clearAuthToken() {
    _headers.remove('Authorization');
  }

  // Generic GET request
  Future<ApiResponse> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      debugPrint('API GET: $uri');

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

  // Generic POST request
  Future<ApiResponse> post(String endpoint, dynamic data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      debugPrint('API POST: $uri');
      debugPrint('Request data: $data');

      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(data),
      ).timeout(timeout);

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

  // Handle HTTP response
  ApiResponse _handleResponse(http.Response response) {
    debugPrint('API Response Status: ${response.statusCode}');
    debugPrint('API Response Body: ${response.body}');

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
        message: responseData['message'],
      );
    } else {
      final errorMessage = responseData['message'] ??
          responseData['error'] ??
          'HTTP $statusCode';
      throw ApiException(errorMessage, statusCode);
    }
  }
}