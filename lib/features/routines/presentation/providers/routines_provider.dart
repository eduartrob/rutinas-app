import 'package:flutter/material.dart';
import '../../domain/entities/routine_entity.dart';
import '../../domain/usecases/routine_usecases.dart';

/// Routines state enum
enum RoutinesStatus {
  initial,
  loading,
  success,
  error,
}

/// Routines provider following MVVM pattern
class RoutinesProvider extends ChangeNotifier {
  final GetRoutinesUseCase getRoutinesUseCase;
  final CreateRoutineUseCase createRoutineUseCase;
  final UpdateRoutineUseCase updateRoutineUseCase;
  final ToggleRoutineUseCase toggleRoutineUseCase;
  final DeleteRoutineUseCase deleteRoutineUseCase;

  RoutinesProvider({
    required this.getRoutinesUseCase,
    required this.createRoutineUseCase,
    required this.updateRoutineUseCase,
    required this.toggleRoutineUseCase,
    required this.deleteRoutineUseCase,
  });

  RoutinesStatus _status = RoutinesStatus.initial;
  List<RoutineEntity> _routines = [];
  String? _errorMessage;

  // Getters
  RoutinesStatus get status => _status;
  List<RoutineEntity> get routines => _routines;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == RoutinesStatus.loading;

  /// Load all routines
  Future<void> loadRoutines() async {
    _status = RoutinesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getRoutinesUseCase();
    result.fold(
      (failure) {
        _status = RoutinesStatus.error;
        _errorMessage = failure.message ?? 'Error al cargar rutinas';
      },
      (routinesList) {
        _status = RoutinesStatus.success;
        _routines = routinesList;
      },
    );
    notifyListeners();
  }

  /// Create a new routine
  Future<bool> createRoutine({
    required String name,
    List<String>? categories,
    List<HabitEntity>? habits,
  }) async {
    _status = RoutinesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await createRoutineUseCase(
      name: name,
      categories: categories,
      habits: habits,
    );

    return result.fold(
      (failure) {
        _status = RoutinesStatus.error;
        _errorMessage = failure.message ?? 'Error al crear rutina';
        notifyListeners();
        return false;
      },
      (routine) {
        _status = RoutinesStatus.success;
        _routines.add(routine);
        notifyListeners();
        return true;
      },
    );
  }

  /// Update an existing routine
  Future<bool> updateRoutine({
    required String id,
    String? name,
    List<HabitEntity>? habits,
    bool? isActive,
    List<String>? categories,
  }) async {
    _status = RoutinesStatus.loading;
    notifyListeners();

    final result = await updateRoutineUseCase(
      id: id,
      name: name,
      habits: habits,
      isActive: isActive,
      categories: categories,
    );

    return result.fold(
      (failure) {
        _status = RoutinesStatus.error;
        _errorMessage = failure.message ?? 'Error al actualizar rutina';
        notifyListeners();
        return false;
      },
      (updatedRoutine) {
        _status = RoutinesStatus.success;
        final index = _routines.indexWhere((r) => r.id == id);
        if (index != -1) {
          _routines[index] = updatedRoutine;
        }
        notifyListeners();
        return true;
      },
    );
  }

  /// Toggle routine active status
  Future<bool> toggleRoutine(String id) async {
    final result = await toggleRoutineUseCase(id);

    return result.fold(
      (failure) {
        _errorMessage = failure.message ?? 'Error al cambiar estado';
        notifyListeners();
        return false;
      },
      (updatedRoutine) {
        final index = _routines.indexWhere((r) => r.id == id);
        if (index != -1) {
          _routines[index] = updatedRoutine;
        }
        notifyListeners();
        return true;
      },
    );
  }

  /// Delete a routine
  Future<bool> deleteRoutine(String id) async {
    final result = await deleteRoutineUseCase(id);

    return result.fold(
      (failure) {
        _errorMessage = failure.message ?? 'Error al eliminar rutina';
        notifyListeners();
        return false;
      },
      (success) {
        _routines.removeWhere((r) => r.id == id);
        notifyListeners();
        return true;
      },
    );
  }
}
