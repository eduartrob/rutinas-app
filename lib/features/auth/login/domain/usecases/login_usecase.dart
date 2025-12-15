import 'package:dartz/dartz.dart';
import 'package:app/core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/login_repository.dart';

/// Use case for login functionality
class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase({required this.repository});

  /// Execute login with email and password
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}
