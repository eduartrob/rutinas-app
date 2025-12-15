import 'package:dartz/dartz.dart';
import 'package:app/core/error/exceptions.dart';
import 'package:app/core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_datasource.dart';
import '../models/login_request_model.dart';

/// Implementation of login repository
class LoginRepositoryImpl implements LoginRepository {
  final LoginRemoteDatasource remoteDatasource;

  LoginRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequestModel(
        email: email,
        password: password,
      );
      final response = await remoteDatasource.login(request);
      return Right(response.data.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message ?? 'Email o contraseña incorrectos'));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(message: e.message ?? 'Datos inválidos'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
