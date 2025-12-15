import 'package:app/features/routines/domain/entities/routine_entity.dart';

/// Habit model for API communication
class HabitModel {
  final String name;
  final String category;
  final String? time;
  final String emoji;

  HabitModel({
    required this.name,
    required this.category,
    this.time,
    required this.emoji,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      time: json['time'],
      emoji: json['emoji'] ?? '📌',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'time': time,
      'emoji': emoji,
    };
  }

  HabitEntity toEntity() {
    return HabitEntity(
      name: name,
      category: category,
      time: time,
      emoji: emoji,
    );
  }

  static HabitModel fromEntity(HabitEntity entity) {
    return HabitModel(
      name: entity.name,
      category: entity.category,
      time: entity.time,
      emoji: entity.emoji,
    );
  }
}

/// Routine model for API communication
class RoutineModel {
  final String id;
  final String name;
  final String userId;
  final List<HabitModel> habits;
  final bool isActive;
  final List<String> categories;
  final DateTime createdAt;

  RoutineModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.habits,
    required this.isActive,
    required this.categories,
    required this.createdAt,
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
      habits: (json['habits'] as List<dynamic>?)
          ?.map((h) => HabitModel.fromJson(h))
          .toList() ?? [],
      isActive: json['isActive'] ?? false,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((c) => c.toString())
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'habits': habits.map((h) => h.toJson()).toList(),
      'isActive': isActive,
      'categories': categories,
    };
  }

  RoutineEntity toEntity() {
    return RoutineEntity(
      id: id,
      name: name,
      userId: userId,
      habits: habits.map((h) => h.toEntity()).toList(),
      isActive: isActive,
      categories: categories,
      createdAt: createdAt,
    );
  }
}

/// Response model for routine API calls
class RoutineResponseModel {
  final String? message;
  final RoutineModel? data;

  RoutineResponseModel({this.message, this.data});

  factory RoutineResponseModel.fromJson(Map<String, dynamic> json) {
    return RoutineResponseModel(
      message: json['message'],
      data: json['data'] != null ? RoutineModel.fromJson(json['data']) : null,
    );
  }
}

/// Response model for routines list
class RoutinesListResponseModel {
  final List<RoutineModel> data;

  RoutinesListResponseModel({required this.data});

  factory RoutinesListResponseModel.fromJson(Map<String, dynamic> json) {
    return RoutinesListResponseModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((r) => RoutineModel.fromJson(r))
          .toList() ?? [],
    );
  }
}
