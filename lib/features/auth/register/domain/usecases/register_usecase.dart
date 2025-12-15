import 'package:dartz/dartz.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/features/auth/login/domain/entities/user_entity.dart';
import '../repositories/register_repository.dart';

/// Use case for register functionality
class RegisterUseCase {
  final RegisterRepository repository;

  RegisterUseCase({required this.repository});

  /// Execute registration
  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    return await repository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
  }
}
