import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import 'package:app/core/services/auth_token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/core/config/api_config.dart';

/// Login state enum for UI state management
enum LoginStatus {
  initial,
  loading,
  success,
  error,
}

/// Login provider following MVVM pattern with user persistence
class LoginProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final AuthTokenService _authService = AuthTokenService();

  LoginProvider({required this.loginUseCase}) {
    // Auto-load user data on initialization
    _loadSavedUser();
  }

  LoginStatus _status = LoginStatus.initial;
  UserEntity? _user;
  String? _errorMessage;
  bool _obscurePassword = true;

  // Getters
  LoginStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _status == LoginStatus.loading;
  bool get isLoggedIn => _user != null;

  /// Load saved user data on app start
  Future<void> _loadSavedUser() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) return;

      // Check if token is expired
      final isExpired = await _authService.isTokenExpired();
      if (isExpired) {
        print('🔒 Token expirado, redirigiendo a login');
        await logout();
        return;
      }

      // Load saved user data
      final userData = await _authService.getUserData();
      if (userData != null) {
        _user = UserEntity(
          id: userData['id'] ?? '',
          name: userData['name'] ?? 'Usuario',
          email: userData['email'] ?? '',
          phone: userData['phone'],
          profileImage: userData['profileImage'],
        );
        _status = LoginStatus.success;
        notifyListeners();
        print('👤 Usuario cargado: ${_user?.name}');
      }
    } catch (e) {
      print('❌ Error al cargar usuario guardado: $e');
    }
  }

  /// Manually refresh user from saved data
  Future<void> refreshUser() async {
    await _loadSavedUser();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _status = LoginStatus.initial;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Logout and clear all data
  Future<void> logout() async {
    await _authService.clearAll();
    _user = null;
    _status = LoginStatus.initial;
    _errorMessage = null;
    notifyListeners();
    print('🚪 Usuario deslogueado');
  }

  /// Perform login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = LoginStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await loginUseCase(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        _status = LoginStatus.error;
        _errorMessage = failure.message ?? 'Error al iniciar sesión';
        notifyListeners();
        return false;
      },
      (user) async {
        _status = LoginStatus.success;
        _user = user;
        
        // Save user data for persistence
        await _authService.saveUserData(
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          profileImage: user.profileImage,
        );
        
        notifyListeners();
        return true;
      },
    );
  }

  /// Update user data locally
  void updateUserLocally({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) {
    if (_user == null) return;
    
    _user = UserEntity(
      id: _user!.id,
      name: name ?? _user!.name,
      email: email ?? _user!.email,
      phone: phone ?? _user!.phone,
      profileImage: profileImage ?? _user!.profileImage,
    );
    
    // Save updated data
    _authService.saveUserData(
      id: _user!.id,
      name: _user!.name,
      email: _user!.email,
      phone: _user!.phone,
      profileImage: _user!.profileImage,
    );
    
    
    notifyListeners();
  }

  /// Upload profile image to backend
  Future<void> uploadProfileImage(String filePath) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      // 1. Upload to S3
      final uri = Uri.parse('${ApiConfig.apiUrl}/s3/upload-image-profile');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final fileUrl = data['fileUrl'];
        if (fileUrl != null) {
          // 2. Update local state
          updateUserLocally(profileImage: fileUrl);
          
          // 3. Save URL to backend user record
          final updateResponse = await http.put(
            Uri.parse('${ApiConfig.apiUrl}/users/update-user'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'profileImage': fileUrl}),
          );
          
          if (updateResponse.statusCode == 200) {
            print('✅ Imagen subida y guardada en servidor: $fileUrl');
          } else {
            print('⚠️ Imagen subida a S3 pero no se guardó en perfil: ${updateResponse.body}');
          }
        }
      } else {
        print('❌ Error al subir imagen (Status ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ Error de excepción al subir imagen: $e');
    }
  }
}
