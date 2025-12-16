import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/progress/presentation/providers/progress_provider.dart';

/// Widget para mostrar un hábito individual con checkbox de completado
class HabitTile extends StatelessWidget {
  final String habitId;
  final String emoji;
  final String name;
  final String time;
  final String category;
  final VoidCallback? onCompletionChanged;

  const HabitTile({
    super.key,
    required this.habitId,
    required this.emoji,
    required this.name,
    required this.time,
    required this.category,
    this.onCompletionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Consumer<ProgressProvider>(
      builder: (context, provider, _) {
        final isCompleted = provider.isHabitCompleted(habitId);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  provider.toggleHabitCompletion(habitId, name);
                  onCompletionChanged?.call();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCompleted ? colorScheme.primary : colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(Icons.check, color: colorScheme.onPrimary, size: 18)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                time,
                style: TextStyle(
                  color: isCompleted 
                      ? colorScheme.onSurface.withOpacity(0.5) 
                      : colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: isCompleted 
                        ? colorScheme.onSurface.withOpacity(0.5) 
                        : colorScheme.onSurface,
                    fontSize: 16,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
