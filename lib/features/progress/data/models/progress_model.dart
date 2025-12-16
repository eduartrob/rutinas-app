import '../../domain/entities/progress_entity.dart';

/// Model for progress statistics with JSON serialization
class ProgressStatsModel extends ProgressStatsEntity {
  const ProgressStatsModel({
    required super.currentStreak,
    required super.successRate,
    required super.completedThisPeriod,
    required List<DailyCompletionModel> dailyCompletions,
    required List<HabitStatModel> habitStats,
  }) : super(
    dailyCompletions: dailyCompletions,
    habitStats: habitStats,
  );

  factory ProgressStatsModel.fromJson(Map<String, dynamic> json) {
    return ProgressStatsModel(
      currentStreak: json['currentStreak'] ?? 0,
      successRate: json['successRate'] ?? 0,
      completedThisPeriod: json['completedThisPeriod'] ?? 0,
      dailyCompletions: (json['dailyCompletions'] as List?)
          ?.map((e) => DailyCompletionModel.fromJson(e))
          .toList() ?? [],
      habitStats: (json['habitStats'] as List?)
          ?.map((e) => HabitStatModel.fromJson(e))
          .toList() ?? [],
    );
  }

  factory ProgressStatsModel.empty() {
    return const ProgressStatsModel(
      currentStreak: 0,
      successRate: 0,
      completedThisPeriod: 0,
      dailyCompletions: [],
      habitStats: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'successRate': successRate,
      'completedThisPeriod': completedThisPeriod,
      'dailyCompletions': dailyCompletions.map((d) => 
        (d as DailyCompletionModel).toJson()).toList(),
      'habitStats': habitStats.map((h) => 
        (h as HabitStatModel).toJson()).toList(),
    };
  }
}

/// Model for daily completion data
class DailyCompletionModel extends DailyCompletionEntity {
  const DailyCompletionModel({
    required super.date,
    required super.count,
  });

  factory DailyCompletionModel.fromJson(Map<String, dynamic> json) {
    return DailyCompletionModel(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'count': count};
  }
}

/// Model for habit statistics
class HabitStatModel extends HabitStatEntity {
  const HabitStatModel({
    required super.habitId,
    required super.name,
    required super.emoji,
    required super.streak,
    required super.percentage,
  });

  factory HabitStatModel.fromJson(Map<String, dynamic> json) {
    return HabitStatModel(
      habitId: json['habitId'] ?? '',
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '📌',
      streak: json['streak'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'name': name,
      'emoji': emoji,
      'streak': streak,
      'percentage': percentage,
    };
  }
}
