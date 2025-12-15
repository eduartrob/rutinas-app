import 'package:flutter/material.dart';
import 'package:app/features/auth/recovery_password/domain/usecases/recovery_password_usecases.dart';

/// Recovery password state enum
enum RecoveryPasswordStatus {
  initial,
  loading,
  success,
  error,
}

/// Recovery password step enum
enum RecoveryPasswordStep {
  forgotPassword,
  verifyCode,
  resetPassword,
  completed,
}

/// Recovery password provider following MVVM pattern
class RecoveryPasswordProvider extends ChangeNotifier {
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyCodeUseCase verifyCodeUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  RecoveryPasswordProvider({
    required this.forgotPasswordUseCase,
    required this.verifyCodeUseCase,
    required this.resetPasswordUseCase,
  });

  RecoveryPasswordStatus _status = RecoveryPasswordStatus.initial;
  RecoveryPasswordStep _step = RecoveryPasswordStep.forgotPassword;
  String? _errorMessage;
  String? _email;
  int? _verificationCode;

  // Getters
  RecoveryPasswordStatus get status => _status;
  RecoveryPasswordStep get step => _step;
  String? get errorMessage => _errorMessage;
  String? get email => _email;
  bool get isLoading => _status == RecoveryPasswordStatus.loading;

  /// Reset state
  void reset() {
    _status = RecoveryPasswordStatus.initial;
    _step = RecoveryPasswordStep.forgotPassword;
    _errorMessage = null;
    _email = null;
    _verificationCode = null;
    notifyListeners();
  }

  /// Step 1: Request password reset (forgot password)
  Future<bool> forgotPassword({required String email}) async {
    _status = RecoveryPasswordStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await forgotPasswordUseCase(email: email);

    return result.fold(
      (failure) {
        _status = RecoveryPasswordStatus.error;
        _errorMessage = failure.message ?? 'Error al enviar el código';
        notifyListeners();
        return false;
      },
      (success) {
        _status = RecoveryPasswordStatus.success;
        _email = email;
        _step = RecoveryPasswordStep.verifyCode;
        notifyListeners();
        return true;
      },
    );
  }

  /// Step 2: Verify reset code
  Future<bool> verifyCode({required int code}) async {
    _status = RecoveryPasswordStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await verifyCodeUseCase(code: code);

    return result.fold(
      (failure) {
        _status = RecoveryPasswordStatus.error;
        _errorMessage = failure.message ?? 'Código inválido';
        notifyListeners();
        return false;
      },
      (success) {
        _status = RecoveryPasswordStatus.success;
        _verificationCode = code;
        _step = RecoveryPasswordStep.resetPassword;
        notifyListeners();
        return true;
      },
    );
  }

  /// Step 3: Reset password
  Future<bool> resetPassword({required String newPassword}) async {
    if (_verificationCode == null) {
      _errorMessage = 'Código de verificación no encontrado';
      _status = RecoveryPasswordStatus.error;
      notifyListeners();
      return false;
    }

    _status = RecoveryPasswordStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await resetPasswordUseCase(
      code: _verificationCode!,
      newPassword: newPassword,
    );

    return result.fold(
      (failure) {
        _status = RecoveryPasswordStatus.error;
        _errorMessage = failure.message ?? 'Error al cambiar contraseña';
        notifyListeners();
        return false;
      },
      (success) {
        _status = RecoveryPasswordStatus.success;
        _step = RecoveryPasswordStep.completed;
        notifyListeners();
        return true;
      },
    );
  }
}
