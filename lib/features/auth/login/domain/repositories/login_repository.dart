import '../entities/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:app/core/error/failures.dart';

/// Login repository interface
abstract class LoginRepository {
  /// Authenticate user with email and password
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });
}
