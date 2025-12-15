import 'package:dartz/dartz.dart';
import 'package:app/core/error/exceptions.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/features/auth/login/domain/entities/user_entity.dart';
import 'package:app/features/auth/register/domain/repositories/register_repository.dart';
import '../datasources/register_remote_datasource.dart';
import '../models/register_request_model.dart';

/// Implementation of register repository
class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDatasource remoteDatasource;

  RegisterRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final request = RegisterRequestModel(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      final response = await remoteDatasource.register(request);
      return Right(response.data.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on ConflictException catch (e) {
      return Left(BadRequestFailure(message: e.message ?? 'El usuario ya existe'));
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(message: e.message ?? 'Datos inválidos'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
