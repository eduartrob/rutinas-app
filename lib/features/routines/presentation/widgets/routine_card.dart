import 'package:flutter/material.dart';
import '../../domain/entities/routine_entity.dart';

/// Routine card widget for the routines list
class RoutineCard extends StatelessWidget {
  final RoutineEntity routine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const RoutineCard({
    super.key,
    required this.routine,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  String _getEmojis() {
    if (routine.habits.isEmpty) return '📋';
    return routine.habits.take(3).map((h) => h.emoji).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252537),
        borderRadius: BorderRadius.circular(16),
        border: routine.isActive 
          ? Border.all(color: const Color(0xFF4CAF50), width: 2)
          : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getEmojis(),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activar',
                style: TextStyle(color: Colors.white70),
              ),
              Switch(
                value: routine.isActive,
                onChanged: onToggle,
                activeColor: const Color(0xFF4CAF50),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
