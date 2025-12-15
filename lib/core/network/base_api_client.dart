import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_client_provider.dart';
import '../error/exceptions.dart';
import '../services/auth_token_service.dart';

/// HTTP client with GET, POST, and DELETE methods for API communication.
class BaseApiClient {
  final http.Client _client; 
  final AuthTokenService _authTokenService = AuthTokenService();
  
  BaseApiClient() : _client = HttpClientProvider().client;

  /// Get headers with auth token from secure storage
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authTokenService.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// GET request
  Future<dynamic> get({
    required String url, 
    Map<String, dynamic>? params,
  }) async {
    final uri = Uri.parse(url).replace(
      queryParameters: params?.map((key, value) => MapEntry(key, value.toString())),
    );

    try {
      final response = await _client.get(
        uri,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 20));

      return _handleResponse(response);
      
    } on Exception catch (e) {
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  /// POST request
  Future<dynamic> post({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(url);

    try {
      final response = await _client.post(
        uri,
        headers: await _getHeaders(),
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(seconds: 20));

      // Auto-capture Authorization token from response headers
      final authHeader = response.headers['authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7); // Remove "Bearer " prefix
        await _authTokenService.saveToken(token);
      }

      return _handleResponse(response);
      
    } on Exception catch (e) {
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  /// DELETE request
  Future<dynamic> delete({
    required String url,
  }) async {
    final uri = Uri.parse(url);

    try {
      final response = await _client.delete(
        uri,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 20));

      return _handleResponse(response);
      
    } on Exception catch (e) {
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  /// PUT request
  Future<dynamic> put({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(url);

    try {
      final response = await _client.put(
        uri,
        headers: await _getHeaders(),
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(seconds: 20));

      return _handleResponse(response);
      
    } on Exception catch (e) {
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  /// Handle HTTP response and errors
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body); 
    } 
    
    // Try to extract error message from response body
    String? errorMessage;
    try {
      final body = json.decode(response.body);
      errorMessage = body['message'] ?? body['error'];
    } catch (_) {}
    
    switch (response.statusCode) {
      case 400:
        throw BadRequestException(errorMessage ?? 'Solicitud inválida (400)');
      case 401:
        throw UnauthorizedException(errorMessage ?? 'No autorizado (401)');
      case 404:
        throw NotFoundException(errorMessage ?? 'Recurso no encontrado (404)');
      case 406:
        throw BadRequestException(errorMessage ?? 'Campos requeridos (406)');
      case 409:
        throw ConflictException(errorMessage ?? 'Conflicto - recurso ya existe (409)');
      case 500:
        throw ServerException(errorMessage ?? 'Error interno del servidor (500)');
      default:
        throw UnknownException(errorMessage ?? 'Error desconocido: ${response.statusCode}');
    }
  }

  /// Clear auth token (logout)
  Future<void> clearAuthToken() async {
    await _authTokenService.clearAll();
  }
}