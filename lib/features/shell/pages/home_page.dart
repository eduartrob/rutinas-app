import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:app/features/routines/presentation/pages/routine_detail_page.dart';
import 'package:app/features/routines/presentation/pages/popular_routine_detail_page.dart';
import 'package:app/features/routines/presentation/providers/routines_provider.dart';
import 'package:app/features/routines/domain/entities/routine_entity.dart';
import 'package:app/features/progress/presentation/providers/progress_provider.dart';
import 'package:app/features/auth/login/presentation/providers/login_provider.dart';
import 'package:app/core/services/notification_service.dart';
import 'package:app/core/services/local_storage_service.dart';
import 'package:app/core/widgets/animated_entrance.dart';
import 'package:app/features/routines/data/datasources/popular_routines_datasource.dart';
import 'package:app/features/shell/widgets/widgets.dart';

/// Página de inicio mostrando los hábitos del día con progreso
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotificationService _notificationService = NotificationService();
  final LocalStorageService _localStorage = LocalStorageService();
  final PopularRoutinesDatasource _popularDatasource = PopularRoutinesDatasource();
  int _pendingSyncCount = 0;
  List<Map<String, dynamic>> _popularRoutines = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    context.read<RoutinesProvider>().loadRoutines();
    context.read<ProgressProvider>().loadTodayCompletions();
    
    _pendingSyncCount = await _localStorage.getPendingSyncCount();
    if (_pendingSyncCount > 0) {
      _trySync();
    }
    
    final popularRoutines = await _popularDatasource.getPopularRoutines();
    if (mounted) {
      setState(() {
        _popularRoutines = popularRoutines;
      });
    }
    
    await _notificationService.initialize();
    final hasPermission = await _notificationService.requestPermissions();
    if (hasPermission) {
      _scheduleHabitNotifications();
    }
    
    if (mounted) setState(() {});
  }

  Future<void> _trySync() async {
    final synced = await _localStorage.syncWithCloud();
    if (synced && mounted) {
      _pendingSyncCount = 0;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Progreso sincronizado'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _scheduleHabitNotifications() {
    final routinesProvider = context.read<RoutinesProvider>();
    final activeRoutines = routinesProvider.routines.where((r) => r.isActive);
    
    for (final routine in activeRoutines) {
      final habitData = routine.habits.map((h) => (
        id: h.id,
        name: h.name,
        emoji: h.emoji,
        time: h.time,
      )).toList();
      
      _notificationService.scheduleRoutineNotifications(
        routineId: routine.id ?? routine.name,
        routineName: routine.name,
        habits: habitData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con foto de usuario
              _buildHeader(colorScheme),
              const SizedBox(height: 24),

              // Sección de rutina de hoy
              AnimatedEntrance(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Tu Rutina de Hoy',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hábitos de rutinas activas
              _buildTodayHabits(colorScheme),
              const SizedBox(height: 32),

              // Sección de rutinas activas
              AnimatedEntrance(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Rutinas Activas',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildActiveRoutines(colorScheme),
              const SizedBox(height: 32),

              // Sección de rutinas populares
              Text(
                'Rutinas Populares',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Descubre rutinas que otros usuarios usan',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _buildPopularRoutinesSection(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, _) {
        final user = loginProvider.user;
        return Row(
          children: [
            _buildUserAvatar(user?.profileImage, colorScheme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${user?.name?.split(' ').first ?? 'Usuario'}',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '¡Vamos a cumplir tus metas!',
                    style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
                  ),
                ],
              ),
            ),
            if (_pendingSyncCount > 0)
              IconButton(
                icon: Badge(
                  label: Text('$_pendingSyncCount'),
                  child: const Icon(Icons.cloud_off),
                ),
                color: Colors.orange,
                onPressed: _trySync,
                tooltip: 'Pendiente de sincronizar',
              )
            else
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
                onPressed: () {},
              ),
          ],
        );
      },
    );
  }

  Widget _buildTodayHabits(ColorScheme colorScheme) {
    return Consumer2<RoutinesProvider, ProgressProvider>(
      builder: (context, routinesProvider, progressProvider, _) {
        if (routinesProvider.isLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          );
        }

        final activeRoutines = routinesProvider.routines.where((r) => r.isActive).toList();
        final allHabitsWithIds = <({HabitEntity habit, String? habitId})>[];
        
        for (final routine in activeRoutines) {
          for (final habit in routine.habits) {
            allHabitsWithIds.add((habit: habit, habitId: null));
          }
        }

        if (allHabitsWithIds.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.event_note, color: colorScheme.onSurface.withOpacity(0.5), size: 48),
                const SizedBox(height: 12),
                Text(
                  'No tienes hábitos activos hoy',
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea una rutina y actívala para ver tus hábitos aquí',
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: allHabitsWithIds.map((item) => HabitTile(
              habitId: item.habit.id,
              emoji: item.habit.emoji,
              name: item.habit.name,
              time: item.habit.time ?? '--:--',
              category: item.habit.category,
            )).toList(),
          ),
        );
      },
    );
  }

  Widget _buildActiveRoutines(ColorScheme colorScheme) {
    return Consumer<RoutinesProvider>(
      builder: (context, provider, _) {
        final activeRoutines = provider.routines.where((r) => r.isActive).toList();

        if (activeRoutines.isEmpty) {
          return Container(
            height: 120,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No tienes rutinas activas',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: activeRoutines.length,
            itemBuilder: (context, index) {
              final routine = activeRoutines[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoutineDetailPage(routine: routine),
                    ),
                  );
                },
                child: RoutineCard(
                  name: routine.name,
                  habitCount: routine.habits.length,
                  categories: routine.categories,
                  habits: routine.habits,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPopularRoutinesSection(ColorScheme colorScheme) {
    if (_popularRoutines.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _popularRoutines.length,
        itemBuilder: (context, index) {
          final template = _popularRoutines[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PopularRoutineDetailPage(template: template),
                ),
              );
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(template['emoji'] as String, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          template['name'] as String,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, 
                           size: 14, 
                           color: colorScheme.onSurface.withOpacity(0.5)),
                      const SizedBox(width: 4),
                      Text(
                        '${template['habitCount']} hábitos',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserAvatar(String? profileImage, ColorScheme colorScheme) {
    if (profileImage != null && profileImage.startsWith('/')) {
      final file = File(profileImage);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: 24,
          backgroundImage: FileImage(file),
        );
      }
    }
    
    if (profileImage != null && profileImage.startsWith('http')) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(profileImage),
        onBackgroundImageError: (_, __) {},
        child: Icon(Icons.person, color: colorScheme.onPrimary, size: 28),
      );
    }
    
    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.primary,
      child: Icon(Icons.person, color: colorScheme.onPrimary, size: 28),
    );
  }
}
