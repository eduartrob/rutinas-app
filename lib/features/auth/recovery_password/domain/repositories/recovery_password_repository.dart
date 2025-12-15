import 'package:dartz/dartz.dart';
import 'package:app/core/error/failures.dart';

/// Recovery password repository interface
abstract class RecoveryPasswordRepository {
  /// Request password reset - sends code to email
  Future<Either<Failure, bool>> forgotPassword({required String email});
  
  /// Verify reset code
  Future<Either<Failure, bool>> verifyCode({required int code});
  
  /// Reset password with code
  Future<Either<Failure, bool>> resetPassword({
    required int code,
    required String newPassword,
  });
}
