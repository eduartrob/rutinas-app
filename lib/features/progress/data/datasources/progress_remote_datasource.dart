import 'package:app/core/config/api_config.dart';
import 'package:app/core/network/base_api_client.dart';

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
  Future<ProgressStats> getProgressStats({String period = 'week'}) async {
    final response = await apiClient.get(
      url: '${ApiConfig.progressStatsEndpoint}?period=$period',
    );
    return ProgressStats.fromJson(response);
  }
}

/// Progress statistics model
class ProgressStats {
  final int currentStreak;
  final int successRate;
  final int completedThisPeriod;
  final List<DailyCompletion> dailyCompletions;
  final List<HabitStat> habitStats;

  ProgressStats({
    required this.currentStreak,
    required this.successRate,
    required this.completedThisPeriod,
    required this.dailyCompletions,
    required this.habitStats,
  });

  factory ProgressStats.fromJson(Map<String, dynamic> json) {
    return ProgressStats(
      currentStreak: json['currentStreak'] ?? 0,
      successRate: json['successRate'] ?? 0,
      completedThisPeriod: json['completedThisPeriod'] ?? 0,
      dailyCompletions: (json['dailyCompletions'] as List?)
          ?.map((e) => DailyCompletion.fromJson(e))
          .toList() ?? [],
      habitStats: (json['habitStats'] as List?)
          ?.map((e) => HabitStat.fromJson(e))
          .toList() ?? [],
    );
  }

  /// Empty stats for when there's no data
  factory ProgressStats.empty() {
    return ProgressStats(
      currentStreak: 0,
      successRate: 0,
      completedThisPeriod: 0,
      dailyCompletions: [],
      habitStats: [],
    );
  }
}

class DailyCompletion {
  final String date;
  final int count;

  DailyCompletion({required this.date, required this.count});

  factory DailyCompletion.fromJson(Map<String, dynamic> json) {
    return DailyCompletion(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class HabitStat {
  final String habitId;
  final String name;
  final String emoji;
  final int streak;
  final int percentage;

  HabitStat({
    required this.habitId,
    required this.name,
    required this.emoji,
    required this.streak,
    required this.percentage,
  });

  factory HabitStat.fromJson(Map<String, dynamic> json) {
    return HabitStat(
      habitId: json['habitId'] ?? '',
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '📌',
      streak: json['streak'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }
}
