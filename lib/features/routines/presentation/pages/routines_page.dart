import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routines_provider.dart';
import '../widgets/routine_card.dart';
import 'create_routine_page.dart';

/// Routines list page - "Mis Rutinas"
class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutinesProvider>().loadRoutines();
    });
  }

  void _onCreateRoutine() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateRoutinePage()),
    );
    if (result == true && mounted) {
      context.read<RoutinesProvider>().loadRoutines();
    }
  }

  void _onEditRoutine(String routineId) async {
    final routine = context.read<RoutinesProvider>().routines.firstWhere(
      (r) => r.id == routineId,
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreateRoutinePage(routine: routine)),
    );
    if (result == true && mounted) {
      context.read<RoutinesProvider>().loadRoutines();
    }
  }

  void _onDeleteRoutine(String routineId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252537),
        title: const Text('Eliminar Rutina', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro que deseas eliminar esta rutina?', 
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      await context.read<RoutinesProvider>().deleteRoutine(routineId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mis Rutinas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<RoutinesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.routines.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            );
          }

          if (provider.routines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.playlist_add,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes rutinas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea tu primera rutina',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.routines.length,
            itemBuilder: (context, index) {
              final routine = provider.routines[index];
              return RoutineCard(
                routine: routine,
                onEdit: () => _onEditRoutine(routine.id),
                onDelete: () => _onDeleteRoutine(routine.id),
                onToggle: (value) {
                  provider.toggleRoutine(routine.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: _onCreateRoutine,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
