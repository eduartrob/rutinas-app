import '../entities/progress_entity.dart';

/// Repository interface for progress operations
abstract class ProgressRepository {
  /// Toggle habit completion for a date
  Future<bool> toggleHabitCompletion(String habitId, {DateTime? date});

  /// Get completed habit IDs for a date
  Future<List<String>> getCompletionsForDate({DateTime? date});

  /// Get progress statistics
  Future<ProgressStatsEntity> getProgressStats({String period = 'week'});
}
