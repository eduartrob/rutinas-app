import 'package:flutter/material.dart';
import '../../domain/entities/routine_entity.dart';
import 'package:app/core/services/local_storage_service.dart';
import 'package:provider/provider.dart';
import 'package:app/features/progress/presentation/providers/progress_provider.dart';

/// Routine detail page showing all habits in a routine
class RoutineDetailPage extends StatelessWidget {
  final RoutineEntity routine;

  const RoutineDetailPage({super.key, required this.routine});

  Color _getCategoryColor(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('salud') || lowerCategory.contains('ejercicio')) {
      return const Color(0xFFFF7043);
    } else if (lowerCategory.contains('productividad') || lowerCategory.contains('trabajo')) {
      return const Color(0xFF42A5F5);
    } else if (lowerCategory.contains('bienestar') || lowerCategory.contains('meditación')) {
      return const Color(0xFFAB47BC);
    } else if (lowerCategory.contains('educación') || lowerCategory.contains('estudio')) {
      return const Color(0xFF66BB6A);
    }
    return const Color(0xFF4CAF50);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = routine.categories.isNotEmpty 
        ? _getCategoryColor(routine.categories.first) 
        : colorScheme.primary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Consumer<ProgressProvider>(
        builder: (context, provider, _) { 
          final completedCount = routine.habits.where((h) => provider.isHabitCompleted(h.name.hashCode.toString())).length;
          final progress = routine.habits.isEmpty ? 0.0 : completedCount / routine.habits.length;

          return CustomScrollView(
            slivers: [
              // Header with gradient
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: colorScheme.surface,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.8),
                          primaryColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routine.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.checklist, color: Colors.white70, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '${routine.habits.length} hábitos',
                                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: routine.isActive 
                                        ? Colors.green.withOpacity(0.3) 
                                        : Colors.grey.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    routine.isActive ? 'Activa' : 'Inactiva',
                                    style: TextStyle(
                                      color: routine.isActive ? Colors.greenAccent : Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Progress section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progreso de hoy',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$completedCount/${routine.habits.length}',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: colorScheme.outline.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation(primaryColor),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toInt()}% completado',
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Categories
              if (routine.categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 8,
                      children: routine.categories.map((category) => Chip(
                        label: Text(category),
                        backgroundColor: _getCategoryColor(category).withOpacity(0.2),
                        labelStyle: TextStyle(color: _getCategoryColor(category)),
                      )).toList(),
                    ),
                  ),
                ),

              // Habits list header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Hábitos',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Habits list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = routine.habits[index];
                    final habitId = habit.name.hashCode.toString();
                    final isCompleted = provider.isHabitCompleted(habitId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: isCompleted 
                              ? Border.all(color: primaryColor.withOpacity(0.5), width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => provider.toggleHabitCompletion(habitId, habit.name),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isCompleted ? primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCompleted ? primaryColor : colorScheme.outline,
                                    width: 2,
                                  ),
                                ),
                                child: isCompleted
                                    ? Icon(Icons.check, color: colorScheme.onPrimary, size: 20)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(habit.emoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.name,
                                    style: TextStyle(
                                      color: isCompleted 
                                          ? colorScheme.onSurface.withOpacity(0.5)
                                          : colorScheme.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (habit.time != null) ...[
                                        Icon(Icons.access_time, size: 14, color: colorScheme.onSurface.withOpacity(0.5)),
                                        const SizedBox(width: 4),
                                        Text(
                                          habit.time!,
                                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(habit.category).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          habit.category,
                                          style: TextStyle(
                                            color: _getCategoryColor(habit.category),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: routine.habits.length,
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        }
      ),
    );
  }
}
