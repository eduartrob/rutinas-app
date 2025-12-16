/// Entity representing progress statistics
class ProgressStatsEntity {
  final int currentStreak;
  final int successRate;
  final int completedThisPeriod;
  final List<DailyCompletionEntity> dailyCompletions;
  final List<HabitStatEntity> habitStats;

  const ProgressStatsEntity({
    required this.currentStreak,
    required this.successRate,
    required this.completedThisPeriod,
    required this.dailyCompletions,
    required this.habitStats,
  });

  factory ProgressStatsEntity.empty() {
    return const ProgressStatsEntity(
      currentStreak: 0,
      successRate: 0,
      completedThisPeriod: 0,
      dailyCompletions: [],
      habitStats: [],
    );
  }
}

/// Entity for daily completion data
class DailyCompletionEntity {
  final String date;
  final int count;

  const DailyCompletionEntity({
    required this.date,
    required this.count,
  });
}

/// Entity for habit statistics
class HabitStatEntity {
  final String habitId;
  final String name;
  final String emoji;
  final int streak;
  final int percentage;

  const HabitStatEntity({
    required this.habitId,
    required this.name,
    required this.emoji,
    required this.streak,
    required this.percentage,
  });
}
