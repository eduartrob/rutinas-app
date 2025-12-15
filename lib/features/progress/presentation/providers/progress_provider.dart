import 'package:flutter/material.dart';
import '../../data/datasources/progress_remote_datasource.dart';
import 'package:app/core/services/local_storage_service.dart';

/// Provider for progress/habit completion tracking
class ProgressProvider extends ChangeNotifier {
  final ProgressRemoteDatasource datasource;
  final LocalStorageService _localStorage = LocalStorageService();

  ProgressProvider({required this.datasource});

  ProgressStats _stats = ProgressStats.empty();
  Set<String> _completedHabitIds = {};
  int _todayCompletedCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  ProgressStats get stats => _stats;
  Set<String> get completedHabitIds => _completedHabitIds;
  int get todayCompletedCount => _todayCompletedCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if a habit is completed today
  bool isHabitCompleted(String habitId) => _completedHabitIds.contains(habitId);

  /// Load completions for today (from local storage first, then try API)
  Future<void> loadTodayCompletions() async {
    try {
      // First load from local storage
      final localCompletions = await _localStorage.getCompletionsForDate(DateTime.now());
      _completedHabitIds = localCompletions
          .where((c) => c['completed'] == true)
          .map((c) => c['habitId'] as String)
          .toSet();
      _todayCompletedCount = _completedHabitIds.length;
      notifyListeners();

      // Then try to load from API
      try {
        final remoteCompletions = await datasource.getCompletionsForDate();
        // Merge remote completions
        _completedHabitIds.addAll(remoteCompletions.toSet());
        _todayCompletedCount = _completedHabitIds.length;
        notifyListeners();
      } catch (e) {
        debugPrint('📴 No se pudo cargar desde API: $e');
      }
    } catch (e) {
      debugPrint('Error loading completions: $e');
    }
  }

  /// Refresh completion count from local storage
  Future<void> refreshTodayCount() async {
    _todayCompletedCount = await _localStorage.getTodayCompletionCount();
    notifyListeners();
  }

  /// Toggle habit completion
  Future<void> toggleHabitCompletion(String habitId, String habitName) async {
    final wasCompleted = _completedHabitIds.contains(habitId);
    final isNowCompleted = !wasCompleted;

    // 1. Update local state immediately (Optimistic UI)
    if (isNowCompleted) {
      _completedHabitIds.add(habitId);
      _todayCompletedCount++;
    } else {
      _completedHabitIds.remove(habitId);
      _todayCompletedCount--;
    }
    notifyListeners();

    try {
      // 2. Save to local storage (and queue for sync)
      await _localStorage.saveCompletion(
        habitId: habitId,
        habitName: habitName,
        date: DateTime.now(),
        completed: isNowCompleted,
      );

      // 3. Trigger background sync
      // We don't await this to keep UI responsive, and errors are handled by service
      _localStorage.syncWithCloud().then((synced) {
        if (synced) debugPrint('✅ Hábito $habitId sincronizado con nube');
      });

    } catch (e) {
      debugPrint('Error saving/toggling habit: $e');
      // If local save fails, getting back to safe state
      await loadTodayCompletions();
    }
  }

  /// Load progress stats
  Future<void> loadStats({String period = 'week'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First refresh local count
      await refreshTodayCount();
      
      // Then try API
      _stats = await datasource.getProgressStats(period: period);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      
      // Use empty stats with local count if API fails
      _stats = ProgressStats(
        currentStreak: 0,
        successRate: 0,
        completedThisPeriod: _todayCompletedCount,
        dailyCompletions: [],
        habitStats: [],
      );
      notifyListeners();
    }
  }
}
