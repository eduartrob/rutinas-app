import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:app/core/services/auth_token_service.dart';
import 'package:app/core/config/api_config.dart';

/// Service for storing habit completions locally and syncing with cloud
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const _completionsKey = 'habit_completions';
  static const _pendingSyncKey = 'pending_sync';

  final AuthTokenService _authService = AuthTokenService();

  /// Save a habit completion locally
  Future<void> saveCompletion({
    required String habitId,
    required String habitName,
    required DateTime date,
    bool completed = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing completions
    final completions = await getCompletions();
    
    // Create key for today's completions
    final dateKey = _formatDate(date);
    
    if (!completions.containsKey(dateKey)) {
      completions[dateKey] = [];
    }

    // Check if completion already exists
    final existing = (completions[dateKey] as List).firstWhere(
      (c) => c['habitId'] == habitId,
      orElse: () => null,
    );

    if (existing == null) {
      (completions[dateKey] as List).add({
        'habitId': habitId,
        'habitName': habitName,
        'completed': completed,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else {
      existing['completed'] = completed;
      existing['timestamp'] = DateTime.now().toIso8601String();
    }

    await prefs.setString(_completionsKey, jsonEncode(completions));
    
    // Add to pending sync queue
    await _addToPendingSync(habitId, dateKey, completed);
    
    debugPrint('✅ Hábito guardado localmente: $habitName');
  }

  /// Get all completions stored locally
  Future<Map<String, dynamic>> getCompletions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_completionsKey);
      if (data != null) {
        return Map<String, dynamic>.from(jsonDecode(data));
      }
    } catch (e) {
      debugPrint('❌ Error al leer completions: $e');
    }
    return {};
  }

  /// Get completions for a specific date
  Future<List<Map<String, dynamic>>> getCompletionsForDate(DateTime date) async {
    final completions = await getCompletions();
    final dateKey = _formatDate(date);
    if (completions.containsKey(dateKey)) {
      return List<Map<String, dynamic>>.from(completions[dateKey]);
    }
    return [];
  }

  /// Get today's completion count
  Future<int> getTodayCompletionCount() async {
    final today = await getCompletionsForDate(DateTime.now());
    return today.where((c) => c['completed'] == true).length;
  }

  /// Check if a habit is completed today
  Future<bool> isHabitCompletedToday(String habitId) async {
    final today = await getCompletionsForDate(DateTime.now());
    final completion = today.firstWhere(
      (c) => c['habitId'] == habitId,
      orElse: () => {},
    );
    return completion['completed'] == true;
  }

  /// Add to pending sync queue
  Future<void> _addToPendingSync(String habitId, String dateKey, bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingJson = prefs.getString(_pendingSyncKey) ?? '[]';
    final pending = List<Map<String, dynamic>>.from(jsonDecode(pendingJson));
    
    // Remove if already exists for this habit/date
    pending.removeWhere((p) => p['habitId'] == habitId && p['date'] == dateKey);
    
    pending.add({
      'habitId': habitId,
      'date': dateKey,
      'completed': completed,
      'addedAt': DateTime.now().toIso8601String(),
    });
    
    await prefs.setString(_pendingSyncKey, jsonEncode(pending));
  }

  /// Sync pending completions with cloud
  Future<bool> syncWithCloud() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        debugPrint('⚠️ Sin token, no se puede sincronizar');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final pendingJson = prefs.getString(_pendingSyncKey) ?? '[]';
      final pending = List<Map<String, dynamic>>.from(jsonDecode(pendingJson));

      if (pending.isEmpty) {
        debugPrint('✅ Nada que sincronizar');
        return true;
      }

      debugPrint('☁️ Sincronizando ${pending.length} completions...');

      for (final item in pending) {
        try {
          final response = await http.post(
            Uri.parse('${ApiConfig.apiUrl}/progress/toggle'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'habitId': item['habitId'],
              'completed': item['completed'],
              'date': item['date'],
            }),
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200 || response.statusCode == 201) {
            debugPrint('☁️ Sincronizado: ${item['habitId']}');
          }
        } catch (e) {
          debugPrint('❌ Error al sincronizar ${item['habitId']}: $e');
          return false; // Stop sync, retry later
        }
      }

      // Clear pending queue after successful sync
      await prefs.remove(_pendingSyncKey);
      debugPrint('✅ Sincronización completada');
      return true;
    } catch (e) {
      debugPrint('❌ Error de sincronización: $e');
      return false;
    }
  }

  /// Get pending sync count
  Future<int> getPendingSyncCount() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingJson = prefs.getString(_pendingSyncKey) ?? '[]';
    final pending = List<dynamic>.from(jsonDecode(pendingJson));
    return pending.length;
  }

  /// Clear completions for a new day (auto-reset)
  Future<void> cleanOldCompletions({int keepDays = 30}) async {
    final completions = await getCompletions();
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));
    
    completions.removeWhere((key, value) {
      try {
        final date = DateTime.parse(key);
        return date.isBefore(cutoff);
      } catch (_) {
        return false;
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_completionsKey, jsonEncode(completions));
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get completion counts for the last 7 days from local storage
  Future<List<Map<String, dynamic>>> getWeeklyCompletions() async {
    final completions = await getCompletions();
    final today = DateTime.now();
    final List<Map<String, dynamic>> weeklyData = [];

    // Iterate backwards from today for 7 days
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = _formatDate(date);
      
      int count = 0;
      if (completions.containsKey(dateKey)) {
        final dayCompletions = List<Map<String, dynamic>>.from(completions[dateKey]);
        count = dayCompletions.where((c) => c['completed'] == true).length;
      }

      weeklyData.add({
        'date': dateKey,
        'count': count,
        'label': _getDayLabel(date.weekday),
      });
    }
    return weeklyData;
  }

  String _getDayLabel(int weekday) {
    switch (weekday) {
      case 1: return 'Lun';
      case 2: return 'Mar';
      case 3: return 'Mié';
      case 4: return 'Jue';
      case 5: return 'Vie';
      case 6: return 'Sáb';
      case 7: return 'Dom';
      default: return '';
    }
  }
}
