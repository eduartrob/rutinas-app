import 'package:flutter/material.dart';
import 'package:app/features/auth/login/domain/entities/user_entity.dart';
import 'package:app/features/auth/register/domain/usecases/register_usecase.dart';

/// Register state enum for UI state management
enum RegisterStatus {
  initial,
  loading,
  success,
  error,
}

/// Register provider following MVVM pattern
class RegisterProvider extends ChangeNotifier {
  final RegisterUseCase registerUseCase;

  RegisterProvider({required this.registerUseCase});

  RegisterStatus _status = RegisterStatus.initial;
  UserEntity? _user;
  String? _errorMessage;
  bool _obscurePassword = true;

  // Getters
  RegisterStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _status == RegisterStatus.loading;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _status = RegisterStatus.initial;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Perform registration
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _status = RegisterStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );

    return result.fold(
      (failure) {
        _status = RegisterStatus.error;
        _errorMessage = failure.message ?? 'Error al registrarse';
        notifyListeners();
        return false;
      },
      (user) {
        _status = RegisterStatus.success;
        _user = user;
        notifyListeners();
        return true;
      },
    );
  }
}
