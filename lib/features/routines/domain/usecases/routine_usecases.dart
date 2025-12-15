import 'package:dartz/dartz.dart';
import 'package:app/core/error/failures.dart';
import '../entities/routine_entity.dart';
import '../repositories/routine_repository.dart';

/// Get all routines use case
class GetRoutinesUseCase {
  final RoutineRepository repository;

  GetRoutinesUseCase({required this.repository});

  Future<Either<Failure, List<RoutineEntity>>> call() async {
    return await repository.getRoutines();
  }
}

/// Create routine use case
class CreateRoutineUseCase {
  final RoutineRepository repository;

  CreateRoutineUseCase({required this.repository});

  Future<Either<Failure, RoutineEntity>> call({
    required String name,
    List<String>? categories,
    List<HabitEntity>? habits,
  }) async {
    return await repository.createRoutine(
      name: name,
      categories: categories,
      habits: habits,
    );
  }
}

/// Update routine use case
class UpdateRoutineUseCase {
  final RoutineRepository repository;

  UpdateRoutineUseCase({required this.repository});

  Future<Either<Failure, RoutineEntity>> call({
    required String id,
    String? name,
    List<HabitEntity>? habits,
    bool? isActive,
    List<String>? categories,
  }) async {
    return await repository.updateRoutine(
      id: id,
      name: name,
      habits: habits,
      isActive: isActive,
      categories: categories,
    );
  }
}

/// Toggle routine use case
class ToggleRoutineUseCase {
  final RoutineRepository repository;

  ToggleRoutineUseCase({required this.repository});

  Future<Either<Failure, RoutineEntity>> call(String id) async {
    return await repository.toggleRoutine(id);
  }
}

/// Delete routine use case
class DeleteRoutineUseCase {
  final RoutineRepository repository;

  DeleteRoutineUseCase({required this.repository});

  Future<Either<Failure, bool>> call(String id) async {
    return await repository.deleteRoutine(id);
  }
}
