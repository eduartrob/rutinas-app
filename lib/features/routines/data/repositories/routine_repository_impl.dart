import 'package:dartz/dartz.dart';
import 'package:app/core/error/exceptions.dart';
import 'package:app/core/error/failures.dart';
import '../../domain/entities/routine_entity.dart';
import '../../domain/repositories/routine_repository.dart';
import '../datasources/routine_remote_datasource.dart';
import '../models/routine_model.dart';

/// Implementation of routine repository
class RoutineRepositoryImpl implements RoutineRepository {
  final RoutineRemoteDatasource remoteDatasource;

  RoutineRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, List<RoutineEntity>>> getRoutines() async {
    try {
      final response = await remoteDatasource.getRoutines();
      final routines = response.data.map((r) => r.toEntity()).toList();
      return Right(routines);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoutineEntity>> getRoutineById(String id) async {
    try {
      final response = await remoteDatasource.getRoutineById(id);
      if (response.data == null) {
        return Left(NotFoundFailure(message: 'Rutina no encontrada'));
      }
      return Right(response.data!.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message ?? 'Rutina no encontrada'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoutineEntity>> createRoutine({
    required String name,
    List<String>? categories,
    List<HabitEntity>? habits,
  }) async {
    try {
      final habitsJson = habits?.map((h) => HabitModel.fromEntity(h).toJson()).toList() ?? [];
      final response = await remoteDatasource.createRoutine({
        'name': name,
        'categories': categories ?? [],
        'habits': habitsJson,
      });
      if (response.data == null) {
        return Left(ServerFailure(message: 'Error al crear rutina'));
      }
      return Right(response.data!.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(message: e.message ?? 'Datos inválidos'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoutineEntity>> updateRoutine({
    required String id,
    String? name,
    List<HabitEntity>? habits,
    bool? isActive,
    List<String>? categories,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (habits != null) data['habits'] = habits.map((h) => HabitModel.fromEntity(h).toJson()).toList();
      if (isActive != null) data['isActive'] = isActive;
      if (categories != null) data['categories'] = categories;
      
      final response = await remoteDatasource.updateRoutine(id, data);
      if (response.data == null) {
        return Left(ServerFailure(message: 'Error al actualizar rutina'));
      }
      return Right(response.data!.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message ?? 'Rutina no encontrada'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RoutineEntity>> toggleRoutine(String id) async {
    try {
      final response = await remoteDatasource.toggleRoutine(id);
      if (response.data == null) {
        return Left(ServerFailure(message: 'Error al cambiar estado'));
      }
      return Right(response.data!.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message ?? 'Rutina no encontrada'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteRoutine(String id) async {
    try {
      await remoteDatasource.deleteRoutine(id);
      return const Right(true);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message ?? 'Rutina no encontrada'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
