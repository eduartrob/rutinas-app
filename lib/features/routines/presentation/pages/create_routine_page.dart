import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/routine_entity.dart';
import '../providers/routines_provider.dart';

/// Create or Edit routine page
class CreateRoutinePage extends StatefulWidget {
  final RoutineEntity? routine; // null for create, set for edit

  const CreateRoutinePage({super.key, this.routine});

  @override
  State<CreateRoutinePage> createState() => _CreateRoutinePageState();
}

class _CreateRoutinePageState extends State<CreateRoutinePage> {
  final _nameController = TextEditingController();
  List<HabitEntity> _habits = [];
  bool _isLoading = false;

  bool get isEditing => widget.routine != null;

  @override
  void initState() {
    super.initState();
    if (widget.routine != null) {
      _nameController.text = widget.routine!.name;
      _habits = List.from(widget.routine!.habits);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addHabit() async {
    final habit = await _showAddHabitDialog();
    if (habit != null) {
      setState(() {
        _habits.add(habit);
      });
    }
  }

  Future<HabitEntity?> _showAddHabitDialog() async {
    final nameController = TextEditingController();
    final timeController = TextEditingController();
    String selectedCategory = 'general';
    String selectedEmoji = '📌';

    final categoryEmojis = {
      'salud_fisica': '🏋️',
      'productividad': '📚',
      'salud_mental': '🧘',
      'hogar': '🏠',
      'general': '📌',
    };

    return await showDialog<HabitEntity>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF252537),
          title: const Text('Añadir Hábito', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nombre del hábito',
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: 'Ej. Correr 30 minutos',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF2A2A3E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Hora (opcional)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: 'Ej. 07:00 AM',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF2A2A3E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  dropdownColor: const Color(0xFF2A2A3E),
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2A2A3E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: categoryEmojis.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text('${e.value} ${e.key.replaceAll('_', ' ').toUpperCase()}',
                        style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                      selectedEmoji = categoryEmojis[value]!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
              ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
                Navigator.pop(
                  context,
                  HabitEntity(
                    id: tempId,
                    name: nameController.text.trim(),
                    category: selectedCategory,
                    time: timeController.text.isNotEmpty ? timeController.text.trim() : null,
                    emoji: selectedEmoji,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text('Añadir'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeHabit(int index) {
    setState(() {
      _habits.removeAt(index);
    });
  }

  void _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un nombre')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<RoutinesProvider>();
    bool success;

    if (isEditing) {
      success = await provider.updateRoutine(
        id: widget.routine!.id,
        name: _nameController.text.trim(),
        habits: _habits,
      );
    } else {
      success = await provider.createRoutine(
        name: _nameController.text.trim(),
        habits: _habits,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error al guardar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Editar Rutina' : 'Crear Nueva Rutina',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Guardar'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name input
            Text(
              'Nombre de la Rutina',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ej. Ritual Matutino',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF252537),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Habits section
            const Text(
              'Añadir Hábitos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Add habit button
            OutlinedButton.icon(
              onPressed: _addHabit,
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4CAF50)),
              label: const Text('Añadir Hábito', style: TextStyle(color: Color(0xFF4CAF50))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            
            // Habits list
            ...List.generate(_habits.length, (index) {
              final habit = _habits[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF252537),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(habit.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (habit.time != null)
                            Text(
                              habit.time!,
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _removeHabit(index),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
