import 'package:dartz/dartz.dart';
import 'package:app/core/error/failures.dart';
import '../repositories/recovery_password_repository.dart';

/// Use case for forgot password - sends reset code to email
class ForgotPasswordUseCase {
  final RecoveryPasswordRepository repository;

  ForgotPasswordUseCase({required this.repository});

  Future<Either<Failure, bool>> call({required String email}) async {
    return await repository.forgotPassword(email: email);
  }
}

/// Use case for verify code
class VerifyCodeUseCase {
  final RecoveryPasswordRepository repository;

  VerifyCodeUseCase({required this.repository});

  Future<Either<Failure, bool>> call({required int code}) async {
    return await repository.verifyCode(code: code);
  }
}

/// Use case for reset password
class ResetPasswordUseCase {
  final RecoveryPasswordRepository repository;

  ResetPasswordUseCase({required this.repository});

  Future<Either<Failure, bool>> call({
    required int code,
    required String newPassword,
  }) async {
    return await repository.resetPassword(code: code, newPassword: newPassword);
  }
}
