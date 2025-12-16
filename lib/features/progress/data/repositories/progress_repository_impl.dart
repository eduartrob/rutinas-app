import '../../domain/entities/progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_datasource.dart';

/// Implementation of ProgressRepository
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressRemoteDatasource remoteDatasource;

  ProgressRepositoryImpl({required this.remoteDatasource});

  @override
  Future<bool> toggleHabitCompletion(String habitId, {DateTime? date}) {
    return remoteDatasource.toggleHabitCompletion(habitId, date: date);
  }

  @override
  Future<List<String>> getCompletionsForDate({DateTime? date}) {
    return remoteDatasource.getCompletionsForDate(date: date);
  }

  @override
  Future<ProgressStatsEntity> getProgressStats({String period = 'week'}) {
    return remoteDatasource.getProgressStats(period: period);
  }
}
