import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:app/features/routines/presentation/pages/routines_page.dart';
import 'package:app/features/routines/presentation/pages/routine_detail_page.dart';
import 'package:app/features/routines/presentation/providers/routines_provider.dart';
import 'package:app/features/routines/domain/entities/routine_entity.dart';
import 'package:app/features/progress/presentation/providers/progress_provider.dart';
import 'package:app/features/progress/data/datasources/progress_remote_datasource.dart';
import 'package:app/features/profile/presentation/pages/profile_page.dart';
import 'package:app/features/auth/login/presentation/providers/login_provider.dart';
import 'package:app/core/services/notification_service.dart';
import 'package:app/core/services/local_storage_service.dart';

/// Página de inicio mostrando los hábitos del día con progreso
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotificationService _notificationService = NotificationService();
  final LocalStorageService _localStorage = LocalStorageService();
  int _pendingSyncCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    // Cargar datos
    context.read<RoutinesProvider>().loadRoutines();
    context.read<ProgressProvider>().loadTodayCompletions();
    
    // Check pending sync
    _pendingSyncCount = await _localStorage.getPendingSyncCount();
    if (_pendingSyncCount > 0) {
      _trySync();
    }
    
    // Inicializar notificaciones
    await _notificationService.initialize();
    
    // Solicitar permisos de notificaciones
    final hasPermission = await _notificationService.requestPermissions();
    if (hasPermission) {
      debugPrint('🔔 Permisos de notificaciones concedidos');
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
        id: h.name.hashCode.toString(),
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
              Consumer<LoginProvider>(
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
              ),
              const SizedBox(height: 24),

              // Sección de rutina de hoy
              Text(
                'Tu Rutina de Hoy',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Hábitos de rutinas activas
              Consumer2<RoutinesProvider, ProgressProvider>(
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
                      children: allHabitsWithIds.map((item) => _HabitTile(
                        emoji: item.habit.emoji,
                        name: item.habit.name,
                        time: item.habit.time ?? '--:--',
                        category: item.habit.category,
                      )).toList(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Sección de rutinas activas
              Text(
                'Rutinas Activas',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Consumer<RoutinesProvider>(
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
                          child: _RoutineCard(
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
              ),

              const SizedBox(height: 32),

              // Sección de rutinas populares/plantillas
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

              // Templates/Popular routines (estáticas por ahora)
              _buildPopularRoutinesSection(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularRoutinesSection(ColorScheme colorScheme) {
    final templates = [
      {
        'name': 'Rutina Matutina Productiva',
        'emoji': '🌅',
        'habitCount': 5,
        'categories': ['Salud', 'Productividad'],
      },
      {
        'name': 'Rutina Nocturna de Descanso',
        'emoji': '🌙',
        'habitCount': 4,
        'categories': ['Salud', 'Bienestar'],
      },
      {
        'name': 'Hábitos de Estudio',
        'emoji': '📚',
        'habitCount': 4,
        'categories': ['Estudio', 'Productividad'],
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Próximamente: usar "${template['name']}"'),
                  backgroundColor: colorScheme.primary,
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
    // Check if it's a local file path
    if (profileImage != null && profileImage.startsWith('/')) {
      final file = File(profileImage);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: 24,
          backgroundImage: FileImage(file),
        );
      }
    }
    
    // Check if it's a network URL
    if (profileImage != null && profileImage.startsWith('http')) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(profileImage),
        onBackgroundImageError: (_, __) {},
        child: Icon(Icons.person, color: colorScheme.onPrimary, size: 28),
      );
    }
    
    // Default avatar
    return CircleAvatar(
      radius: 24,
      backgroundColor: colorScheme.primary,
      child: Icon(Icons.person, color: colorScheme.onPrimary, size: 28),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final String emoji;
  final String name;
  final String time;
  final String category;
  final VoidCallback? onCompletionChanged;

  const _HabitTile({
    required this.emoji,
    required this.name,
    required this.time,
    required this.category,
    this.onCompletionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final habitId = name.hashCode.toString();
    
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

class _RoutineCard extends StatelessWidget {
  final String name;
  final int habitCount;
  final List<String> categories;
  final List<HabitEntity> habits;

  const _RoutineCard({
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

/// Página de estadísticas/progreso con datos reales
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _selectedPeriod = 0; // 0=Semana, 1=Mes, 2=Año
  List<Map<String, dynamic>> _localWeeklyData = [];
  final LocalStorageService _localStorage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLocalData();
      _loadStats();
    });
  }

  Future<void> _loadLocalData() async {
    // Load weekly data from local storage
    final weeklyData = await _localStorage.getWeeklyCompletions();
    setState(() {
      _localWeeklyData = weeklyData;
    });
    // Also refresh today count
    context.read<ProgressProvider>().refreshTodayCount();
  }

  List<Widget> _buildLocalWeeklyBars() {
    if (_localWeeklyData.isEmpty) return [];

    // Find max for normalization
    final counts = _localWeeklyData.map((d) => d['count'] as int).toList();
    final maxCount = counts.isEmpty ? 0 : counts.reduce((a, b) => a > b ? a : b);

    return _localWeeklyData.map((data) {
      final count = data['count'] as int;
      final height = maxCount > 0 ? count / maxCount : 0.0;
      final isToday = data == _localWeeklyData.last;

      return _BarChart(
        label: data['label'],
        height: height,
        count: count,
        isHighlighted: isToday,
      );
    }).toList();
  }

  void _loadStats() {
    final period = _selectedPeriod == 0 ? 'week' : (_selectedPeriod == 1 ? 'month' : 'year');
    context.read<ProgressProvider>().loadStats(period: period);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Progreso'),
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, provider, _) {
          final stats = provider.stats;

          if (provider.isLoading && _localWeeklyData.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de período
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _PeriodTab(label: 'Semana', isSelected: _selectedPeriod == 0, onTap: () {
                        setState(() => _selectedPeriod = 0);
                        _loadStats();
                      }),
                      _PeriodTab(label: 'Mes', isSelected: _selectedPeriod == 1, onTap: () {
                        setState(() => _selectedPeriod = 1);
                        _loadStats();
                      }),
                      _PeriodTab(label: 'Año', isSelected: _selectedPeriod == 2, onTap: () {
                        setState(() => _selectedPeriod = 2);
                        _loadStats();
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Resumen diario
                Text(
                  'Resumen de Hoy',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DailySummaryItem(
                          icon: Icons.check_circle_outline,
                          value: '${provider.todayCompletedCount}',
                          label: 'Completados hoy',
                        ),
                      ),
                      Container(width: 1, height: 50, color: colorScheme.outline.withOpacity(0.3)),
                      Expanded(
                        child: _DailySummaryItem(
                          icon: Icons.local_fire_department,
                          value: '${stats.currentStreak}',
                          label: 'Días de racha',
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // Tarjetas de estadísticas
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Racha Actual',
                        value: '${stats.currentStreak}',
                        subtitle: 'días',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Tasa de Éxito',
                        value: '${stats.successRate}%',
                        subtitle: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Resumen de actividad semanal
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen Semanal',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedPeriod == 0 ? 'Completados esta semana' : 
                        (_selectedPeriod == 1 ? 'Completados este mes' : 'Completados este año'),
                        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stats.completedThisPeriod}',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Gráfica semanal (Priorizar datos locales)
                      if (_localWeeklyData.isNotEmpty)
                        SizedBox(
                          height: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _buildLocalWeeklyBars(),
                          ),
                        )
                      else if (stats.dailyCompletions.isNotEmpty)
                        SizedBox(
                          height: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _buildDailyBars(stats.dailyCompletions),
                          ),
                        )
                      else
                        SizedBox(
                          height: 150,
                          child: Center(
                            child: Text(
                              'Sin datos de actividad',
                              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Desglose de hábitos
                Text(
                  'Desglose de Hábitos',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                if (stats.habitStats.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Completa hábitos para ver estadísticas',
                        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    ),
                  )
                else
                  ...stats.habitStats.map((habit) => _HabitStatCard(
                    name: habit.name,
                    emoji: habit.emoji,
                    streak: habit.streak,
                    percentage: habit.percentage,
                  )),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDailyBars(List<DailyCompletion> completions) {
    final maxCount = completions.map((c) => c.count).reduce((a, b) => a > b ? a : b);
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    
    return completions.asMap().entries.map((entry) {
      final index = entry.key;
      final completion = entry.value;
      final height = maxCount > 0 ? completion.count / maxCount : 0.0;
      final isToday = index == completions.length - 1;
      
      return _BarChart(
        label: days[index % 7],
        height: height,
        count: completion.count,
        isHighlighted: isToday,
      );
    }).toList();
  }
}

class _DailySummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _DailySummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 24,
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
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $subtitle',
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final String label;
  final double height;
  final int count;
  final bool isHighlighted;

  const _BarChart({
    required this.label,
    required this.height,
    this.count = 0,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (count > 0)
          Text(
            '$count',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 10),
          ),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: height > 0 ? (100 * height).clamp(10, 100) : 10,
          decoration: BoxDecoration(
            color: isHighlighted 
                ? colorScheme.primary
                : colorScheme.primary.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
        ),
      ],
    );
  }
}

class _HabitStatCard extends StatelessWidget {
  final String emoji;
  final String name;
  final int streak;
  final int percentage;

  const _HabitStatCard({
    required this.emoji,
    required this.name,
    required this.streak,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Racha: $streak días',
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percentage%',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'completado',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shell principal con navegación inferior
class MainShell extends StatefulWidget {
  final VoidCallback? onLogout;

  const MainShell({super.key, this.onLogout});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const RoutinesPage(),
      const StatsPage(),
      ProfilePage(onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist),
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Progreso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
