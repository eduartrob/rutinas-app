import 'package:dartz/dartz.dart';
import 'package:app/core/error/failures.dart';
import '../entities/routine_entity.dart';

/// Routine repository interface
abstract class RoutineRepository {
  /// Get all routines for current user
  Future<Either<Failure, List<RoutineEntity>>> getRoutines();
  
  /// Get a single routine by ID
  Future<Either<Failure, RoutineEntity>> getRoutineById(String id);
  
  /// Create a new routine
  Future<Either<Failure, RoutineEntity>> createRoutine({
    required String name,
    List<String>? categories,
    List<HabitEntity>? habits,
  });
  
  /// Update an existing routine
  Future<Either<Failure, RoutineEntity>> updateRoutine({
    required String id,
    String? name,
    List<HabitEntity>? habits,
    bool? isActive,
    List<String>? categories,
  });
  
  /// Toggle routine active status
  Future<Either<Failure, RoutineEntity>> toggleRoutine(String id);
  
  /// Delete a routine
  Future<Either<Failure, bool>> deleteRoutine(String id);
}
