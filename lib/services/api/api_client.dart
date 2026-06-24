import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _authToken;

  // Get stored token
  Future<String?> getAuthToken() async {
    if (_authToken == null) {
      _authToken = await _storage.read(key: 'auth_token');
    }
    return _authToken;
  }

  // Save token
  Future<void> saveAuthToken(String token) async {
    _authToken = token;
    await _storage.write(key: 'auth_token', value: token);
  }

  // Clear token
  Future<void> clearAuthToken() async {
    _authToken = null;
    await _storage.delete(key: 'auth_token');
  }

  // Get headers with auth
  Future<Map<String, String>> getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Generic GET request
  Future<http.Response> get(String endpoint, {bool requireAuth = true}) async {
    try {
      final headers = await getHeaders(includeAuth: requireAuth);
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: headers)
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<http.Response> post(String endpoint, {dynamic body, bool requireAuth = false}) async {
    try {
      final headers = await getHeaders(includeAuth: requireAuth);
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<http.Response> put(String endpoint, {dynamic body, bool requireAuth = true}) async {
    try {
      final headers = await getHeaders(includeAuth: requireAuth);
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<http.Response> delete(String endpoint, {bool requireAuth = true}) async {
    try {
      final headers = await getHeaders(includeAuth: requireAuth);
      final response = await http
          .delete(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: headers)
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle response
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      // Token expired or invalid
      clearAuthToken();
      throw ApiException('Authentication required. Please login again.', 401);
    } else if (response.statusCode == 403) {
      throw ApiException('Access forbidden. You don\'t have permission.', 403);
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found.', 404);
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error. Please try again later.', response.statusCode);
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw ApiException(errorBody['detail'] ?? 'Unknown error occurred', response.statusCode);
      } catch (e) {
        throw ApiException('Request failed with status ${response.statusCode}', response.statusCode);
      }
    }
  }

  // Handle errors
  ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    } else if (error is SocketException) {
      return ApiException('No internet connection. Please check your network.', 0);
    } else if (error is HttpException) {
      return ApiException('HTTP error: ${error.message}', 0);
    } else if (error is FormatException) {
      return ApiException('Invalid response format.', 0);
    } else {
      return ApiException('An unexpected error occurred: ${error.toString()}', 0);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException(this.message, this.statusCode);
  
  @override
  String toString() => message;
}
