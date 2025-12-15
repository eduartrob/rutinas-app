import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for securely storing and retrieving authentication tokens and user data
class AuthTokenService {
  static final AuthTokenService _instance = AuthTokenService._internal();
  factory AuthTokenService() => _instance;
  AuthTokenService._internal();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userDataKey = 'user_data';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _cachedToken;
  Map<String, dynamic>? _cachedUserData;

  /// Get the current token (from cache or storage)
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  /// Save token to secure storage
  Future<void> saveToken(String token) async {
    _cachedToken = token;
    await _storage.write(key: _tokenKey, value: token);
    print('🔐 Token guardado en almacenamiento seguro');
  }

  /// Save user ID to secure storage
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Get user ID from secure storage
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Save user data (name, email, phone, profileImage)
  Future<void> saveUserData({
    required String id,
    required String name,
    required String email,
    String? phone,
    String? profileImage,
  }) async {
    final userData = {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
    };
    _cachedUserData = userData;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
    print('👤 Datos de usuario guardados: $name');
  }

  /// Get saved user data
  Future<Map<String, dynamic>?> getUserData() async {
    if (_cachedUserData != null) return _cachedUserData;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataJson = prefs.getString(_userDataKey);
      if (userDataJson != null) {
        _cachedUserData = jsonDecode(userDataJson);
        return _cachedUserData;
      }
    } catch (e) {
      print('❌ Error al leer datos de usuario: $e');
    }
    return null;
  }

  /// Clear all auth data (logout)
  Future<void> clearAll() async {
    _cachedToken = null;
    _cachedUserData = null;
    await _storage.deleteAll();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    print('🚪 Sesión cerrada - datos eliminados');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if token is expired (basic check)
  Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return true;
    
    // Try to decode JWT and check expiration
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false; // Not a JWT
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded);
      
      if (data['exp'] != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(data['exp'] * 1000);
        return DateTime.now().isAfter(expiry);
      }
    } catch (e) {
      print('⚠️ No se pudo verificar expiración del token: $e');
    }
    return false;
  }
}
