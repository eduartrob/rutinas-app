import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/progress/presentation/providers/progress_provider.dart';
import 'package:app/features/progress/data/models/progress_model.dart';
import 'package:app/core/services/local_storage_service.dart';
import 'package:app/features/shell/widgets/widgets.dart';

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
    final weeklyData = await _localStorage.getWeeklyCompletions();
    setState(() {
      _localWeeklyData = weeklyData;
    });
    context.read<ProgressProvider>().refreshTodayCount();
  }

  List<Widget> _buildLocalWeeklyBars() {
    if (_localWeeklyData.isEmpty) return [];

    final counts = _localWeeklyData.map((d) => d['count'] as int).toList();
    final maxCount = counts.isEmpty ? 0 : counts.reduce((a, b) => a > b ? a : b);

    return _localWeeklyData.map((data) {
      final count = data['count'] as int;
      final height = maxCount > 0 ? count / maxCount : 0.0;
      final isToday = data == _localWeeklyData.last;

      return BarChart(
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
                _buildPeriodSelector(colorScheme),
                const SizedBox(height: 24),

                // Resumen diario
                _buildDailySummary(colorScheme, provider, stats),
                const SizedBox(height: 24),

                // Tarjetas de estadísticas
                _buildStatCards(stats),
                const SizedBox(height: 24),

                // Resumen de actividad semanal
                _buildWeeklySummary(colorScheme, stats),
                const SizedBox(height: 24),

                // Desglose de hábitos
                _buildHabitsBreakdown(colorScheme, stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(ColorScheme colorScheme) {
    return Container(
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
    );
  }

  Widget _buildDailySummary(ColorScheme colorScheme, ProgressProvider provider, ProgressStatsModel stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildStatCards(ProgressStatsModel stats) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Racha Actual',
            value: '${stats.currentStreak}',
            subtitle: 'días',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Tasa de Éxito',
            value: '${stats.successRate}%',
            subtitle: '',
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklySummary(ColorScheme colorScheme, ProgressStatsModel stats) {
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
          // Gráfica semanal
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
                children: _buildDailyBars(stats.dailyCompletions.cast<DailyCompletionModel>()),
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
    );
  }

  Widget _buildHabitsBreakdown(ColorScheme colorScheme, ProgressStatsModel stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          ...stats.habitStats.map((habit) => HabitStatCard(
            name: habit.name,
            emoji: habit.emoji,
            streak: habit.streak,
            percentage: habit.percentage,
          )),
      ],
    );
  }

  List<Widget> _buildDailyBars(List<DailyCompletionModel> completions) {
    final maxCount = completions.map((c) => c.count).reduce((a, b) => a > b ? a : b);
    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    
    return completions.asMap().entries.map((entry) {
      final index = entry.key;
      final completion = entry.value;
      final height = maxCount > 0 ? completion.count / maxCount : 0.0;
      final isToday = index == completions.length - 1;
      
      return BarChart(
        label: days[index % 7],
        height: height,
        count: completion.count,
        isHighlighted: isToday,
      );
    }).toList();
  }
}

// Private helper widgets for StatsPage
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
