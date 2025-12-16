import 'package:flutter/material.dart';
import 'package:app/features/routines/domain/entities/routine_entity.dart';

/// Widget de tarjeta para mostrar una rutina activa
class RoutineCard extends StatelessWidget {
  final String name;
  final int habitCount;
  final List<String> categories;
  final List<HabitEntity> habits;

  const RoutineCard({
    super.key,
    required this.name,
    required this.habitCount,
    required this.categories,
    required this.habits,
  });

  Color _getCategoryColor() {
    if (categories.isEmpty) return const Color(0xFF4CAF50);
    final category = categories.first.toLowerCase();
    if (category.contains('salud') || category.contains('ejercicio')) {
      return const Color(0xFFFF7043);
    } else if (category.contains('productividad') || category.contains('trabajo')) {
      return const Color(0xFF42A5F5);
    } else if (category.contains('bienestar') || category.contains('meditación')) {
      return const Color(0xFFAB47BC);
    }
    return const Color(0xFF4CAF50);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor().withOpacity(0.8),
            _getCategoryColor().withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Vista previa de hábitos
          ...habits.take(3).map((habit) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(habit.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    habit.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
          if (habits.length > 3)
            Text(
              '+${habits.length - 3} más',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          const Spacer(),
          Text(
            '$habitCount hábitos',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
