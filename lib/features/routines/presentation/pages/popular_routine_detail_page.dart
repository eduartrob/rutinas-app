import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/routines/presentation/providers/routines_provider.dart';
import 'package:app/features/routines/domain/entities/routine_entity.dart';
import 'package:app/core/widgets/animated_entrance.dart';

/// Page to view a popular routine and add it to user's routines
class PopularRoutineDetailPage extends StatelessWidget {
  final Map<String, dynamic> template;

  const PopularRoutineDetailPage({super.key, required this.template});

  Color _getCategoryColor(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('salud') || lowerCategory.contains('ejercicio')) {
      return const Color(0xFFFF7043);
    } else if (lowerCategory.contains('productividad') || lowerCategory.contains('trabajo')) {
      return const Color(0xFF42A5F5);
    } else if (lowerCategory.contains('bienestar') || lowerCategory.contains('meditación')) {
      return const Color(0xFF7E57C2);
    } else if (lowerCategory.contains('estudio')) {
      return const Color(0xFF4CAF50);
    }
    return const Color(0xFF78909C);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final habits = template['habits'] as List<dynamic>? ?? [];
    final categories = template['categories'] as List<dynamic>? ?? [];
    final primaryColor = categories.isNotEmpty 
        ? _getCategoryColor(categories.first.toString())
        : colorScheme.primary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 180,
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor.withOpacity(0.3),
                      colorScheme.surface,
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
                        AnimatedEntrance(
                          child: Row(
                            children: [
                              Text(
                                template['emoji'] as String? ?? '📋',
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  template['name'] as String? ?? 'Rutina',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedEntrance(
                          delay: const Duration(milliseconds: 100),
                          child: Wrap(
                            spacing: 8,
                            children: categories.map((cat) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cat.toString(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Info section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AnimatedEntrance(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    _InfoCard(
                      icon: Icons.check_circle_outline,
                      value: '${template['habitCount'] ?? habits.length}',
                      label: 'Hábitos',
                      color: primaryColor,
                    ),
                    const SizedBox(width: 12),
                    _InfoCard(
                      icon: Icons.people_outline,
                      value: '${template['usersCount'] ?? '100+'}',
                      label: 'Usuarios',
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Habits section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: AnimatedEntrance(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'Hábitos incluidos',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Habits list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final habit = habits[index];
                return AnimatedEntrance(
                  delay: Duration(milliseconds: 350 + (index * 80)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                habit['emoji'] ?? '📌',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit['name'] ?? 'Hábito',
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (habit['time'] != null)
                                  Text(
                                    habit['time'],
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: habits.length,
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: ScaleInWidget(
        delay: const Duration(milliseconds: 600),
        child: FloatingActionButton.extended(
          onPressed: () => _addRoutine(context),
          backgroundColor: primaryColor,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Añadir a mis rutinas',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _addRoutine(BuildContext context) async {
    final provider = context.read<RoutinesProvider>();
    final habits = (template['habits'] as List<dynamic>? ?? [])
        .map((h) => HabitEntity(
              id: 'temp_${DateTime.now().millisecondsSinceEpoch}_${h['name'].hashCode}',
              name: h['name'] ?? 'Hábito',
              category: h['category'] ?? 'general',
              time: h['time'],
              emoji: h['emoji'] ?? '📌',
            ))
        .toList();

    final success = await provider.createRoutine(
      name: template['name'] as String? ?? 'Nueva Rutina',
      habits: habits,
      categories: (template['categories'] as List<dynamic>?)
          ?.map((c) => c.toString())
          .toList(),
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${template['name']}" añadida a tus rutinas'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Error al añadir rutina'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
