import '../repositories/progress_repository.dart';
import '../entities/progress_entity.dart';

/// Use case for toggling habit completion
class ToggleHabitCompletionUseCase {
  final ProgressRepository repository;

  ToggleHabitCompletionUseCase({required this.repository});

  Future<bool> call(String habitId, {DateTime? date}) {
    return repository.toggleHabitCompletion(habitId, date: date);
  }
}

/// Use case for getting completions for a date
class GetCompletionsForDateUseCase {
  final ProgressRepository repository;

  GetCompletionsForDateUseCase({required this.repository});

  Future<List<String>> call({DateTime? date}) {
    return repository.getCompletionsForDate(date: date);
  }
}

/// Use case for getting progress statistics
class GetProgressStatsUseCase {
  final ProgressRepository repository;

  GetProgressStatsUseCase({required this.repository});

  Future<ProgressStatsEntity> call({String period = 'week'}) {
    return repository.getProgressStats(period: period);
  }
}
