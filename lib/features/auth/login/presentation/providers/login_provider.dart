import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

/// Login state enum for UI state management
enum LoginStatus {
  initial,
  loading,
  success,
  error,
}

/// Login provider following MVVM pattern
class LoginProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  LoginProvider({required this.loginUseCase});

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
      (user) {
        _status = LoginStatus.success;
        _user = user;
        notifyListeners();
        return true;
      },
    );
  }
}
