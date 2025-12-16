import 'package:app/core/config/api_config.dart';
import 'package:app/core/network/base_api_client.dart';
import '../models/progress_model.dart';

/// Data source for progress/habit completion operations
class ProgressRemoteDatasource {
  final BaseApiClient apiClient;

  ProgressRemoteDatasource({required this.apiClient});

  /// Toggle habit completion for a date
  Future<bool> toggleHabitCompletion(String habitId, {DateTime? date}) async {
    final response = await apiClient.post(
      url: ApiConfig.toggleCompletionEndpoint,
      body: {
        'habitId': habitId,
        if (date != null) 'date': date.toIso8601String(),
      },
    );
    return response['completed'] as bool;
  }

  /// Get completed habit IDs for a date
  Future<List<String>> getCompletionsForDate({DateTime? date}) async {
    final queryDate = date ?? DateTime.now();
    final response = await apiClient.get(
      url: '${ApiConfig.completionsEndpoint}?date=${queryDate.toIso8601String().split('T')[0]}',
    );
    return List<String>.from(response['completedHabitIds'] ?? []);
  }

  /// Get progress statistics
  Future<ProgressStatsModel> getProgressStats({String period = 'week'}) async {
    final response = await apiClient.get(
      url: '${ApiConfig.progressStatsEndpoint}?period=$period',
    );
    return ProgressStatsModel.fromJson(response);
  }
}

