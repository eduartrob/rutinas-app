import 'package:dartz/dartz.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/features/auth/login/domain/entities/user_entity.dart';

/// Register repository interface
abstract class RegisterRepository {
  /// Register a new user
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  });
}
