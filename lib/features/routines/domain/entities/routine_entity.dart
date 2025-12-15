import 'package:equatable/equatable.dart';

/// Habit entity for domain layer
class HabitEntity extends Equatable {
  final String name;
  final String category;
  final String? time;
  final String emoji;

  const HabitEntity({
    required this.name,
    required this.category,
    this.time,
    required this.emoji,
  });

  @override
  List<Object?> get props => [name, category, time, emoji];
}

/// Routine entity for domain layer
class RoutineEntity extends Equatable {
  final String id;
  final String name;
  final String userId;
  final List<HabitEntity> habits;
  final bool isActive;
  final List<String> categories;
  final DateTime createdAt;

  const RoutineEntity({
    required this.id,
    required this.name,
    required this.userId,
    required this.habits,
    required this.isActive,
    required this.categories,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, userId, habits, isActive, categories, createdAt];
}
