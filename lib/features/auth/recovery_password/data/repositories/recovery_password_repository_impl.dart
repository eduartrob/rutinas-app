import 'package:dartz/dartz.dart';
import 'package:app/core/error/exceptions.dart';
import 'package:app/core/error/failures.dart';
import 'package:app/features/auth/recovery_password/domain/repositories/recovery_password_repository.dart';
import '../datasources/recovery_password_remote_datasource.dart';

/// Implementation of recovery password repository
class RecoveryPasswordRepositoryImpl implements RecoveryPasswordRepository {
  final RecoveryPasswordRemoteDatasource remoteDatasource;

  RecoveryPasswordRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, bool>> forgotPassword({required String email}) async {
    try {
      final result = await remoteDatasource.forgotPassword(email);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message ?? 'Usuario no encontrado'));
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(message: e.message ?? 'Email inválido'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyCode({required int code}) async {
    try {
      final result = await remoteDatasource.verifyCode(code);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(message: e.message ?? 'Código inválido'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required int code,
    required String newPassword,
  }) async {
    try {
      final result = await remoteDatasource.resetPassword(code, newPassword);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(message: e.message ?? 'Código inválido'));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message ?? 'Usuario no encontrado'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
