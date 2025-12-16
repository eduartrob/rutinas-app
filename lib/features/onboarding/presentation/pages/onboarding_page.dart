import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/routines/presentation/providers/routines_provider.dart';
import 'package:app/features/auth/login/domain/entities/user_entity.dart';
import 'package:app/features/routines/domain/entities/routine_entity.dart';

/// Category data for onboarding
class OnboardingCategory {
  final String id;
  final String name;
  final String emoji;
  final String imagePath;
  bool isSelected;

  OnboardingCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.imagePath,
    this.isSelected = false,
  });
}

/// Onboarding page - Category selection
class OnboardingPage extends StatefulWidget {
  final UserEntity user;
  final VoidCallback onComplete;

  const OnboardingPage({
    super.key,
    required this.user,
    required this.onComplete,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _isLoading = false;
  
  final List<OnboardingCategory> _categories = [
    OnboardingCategory(
      id: 'salud_fisica',
      name: 'Salud Física',
      emoji: '🏋️',
      imagePath: 'assets/images/fitness.jpg',
    ),
    OnboardingCategory(
      id: 'productividad',
      name: 'Productividad y Enfoque',
      emoji: '📚',
      imagePath: 'assets/images/productivity.jpg',
    ),
    OnboardingCategory(
      id: 'salud_mental',
      name: 'Salud Mental y Ocio',
      emoji: '🧘',
      imagePath: 'assets/images/mental.jpg',
    ),
    OnboardingCategory(
      id: 'hogar',
      name: 'Hogar y Cuidado',
      emoji: '🏠',
      imagePath: 'assets/images/home.jpg',
    ),
  ];

  void _toggleCategory(int index) {
    setState(() {
      _categories[index].isSelected = !_categories[index].isSelected;
    });
  }

  List<String> get _selectedCategories {
    return _categories
        .where((c) => c.isSelected)
        .map((c) => c.id)
        .toList();
  }

  void _generateRoutine() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una categoría')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Create routine with selected categories
    final provider = context.read<RoutinesProvider>();
    final success = await provider.createRoutine(
      name: 'Mi Primera Rutina',
      categories: _selectedCategories,
      habits: _generateDefaultHabits(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      widget.onComplete();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error al crear rutina')),
      );
    }
  }

  List<HabitEntity> _generateDefaultHabits() {
    // Generate default habits based on selected categories
    final habits = <HabitEntity>[];
    
    for (final category in _categories.where((c) => c.isSelected)) {
      switch (category.id) {
        case 'salud_fisica':
          habits.add(HabitEntity(
            id: 'temp_fitness_${DateTime.now().millisecondsSinceEpoch}',
            name: 'Ejercicio 30 minutos',
            category: 'salud_fisica',
            time: '07:00 AM',
            emoji: '🏃',
          ));
          break;
        case 'productividad':
          habits.add(HabitEntity(
            id: 'temp_productivity_${DateTime.now().millisecondsSinceEpoch}',
            name: 'Leer 10 páginas',
            category: 'productividad',
            emoji: '📚',
          ));
          break;
        case 'salud_mental':
          habits.add(HabitEntity(
            id: 'temp_mental_${DateTime.now().millisecondsSinceEpoch}',
            name: 'Meditar 15 minutos',
            category: 'salud_mental',
            time: '07:30 AM',
            emoji: '🧘',
          ));
          break;
        case 'hogar':
          habits.add(HabitEntity(
            id: 'temp_home_${DateTime.now().millisecondsSinceEpoch}',
            name: 'Ordenar habitación',
            category: 'hogar',
            emoji: '🏠',
          ));
          break;
      }
    }
    
    return habits;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome text
              Text(
                '¡Bienvenido, ${widget.user.name}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Para empezar, cuéntanos qué áreas te gustaría mejorar. Esto nos ayudará a sugerirte tu primera rutina.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              
              // Categories grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return GestureDetector(
                      onTap: () => _toggleCategory(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: category.isSelected
                              ? Border.all(color: const Color(0xFF4CAF50), width: 3)
                              : null,
                          boxShadow: category.isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50).withAlpha(50),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background color placeholder
                              Container(
                                color: _getCategoryColor(category.id),
                              ),
                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withAlpha(180),
                                    ],
                                  ),
                                ),
                              ),
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      category.emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              // Check mark
                              if (category.isSelected)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4CAF50),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // Generate button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Generar mi primera rutina',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String id) {
    switch (id) {
      case 'salud_fisica':
        return const Color(0xFF3E2723); // Brown
      case 'productividad':
        return const Color(0xFFF5DEB3); // Beige
      case 'salud_mental':
        return const Color(0xFF4A4A4A); // Dark grey
      case 'hogar':
        return const Color(0xFFD4B896); // Light brown
      default:
        return const Color(0xFF252537);
    }
  }
}
