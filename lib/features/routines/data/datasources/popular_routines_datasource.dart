import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/core/config/api_config.dart';
import 'package:app/core/services/auth_token_service.dart';

/// Data source for popular routines from backend
class PopularRoutinesDatasource {
  final AuthTokenService _authService = AuthTokenService();

  /// Get all popular routines
  Future<List<Map<String, dynamic>>> getPopularRoutines() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/popular-routines'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((r) => _transformRoutine(r)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error fetching popular routines: $e');
      return [];
    }
  }

  /// Add popular routine to user's account
  Future<bool> addPopularRoutine(String routineId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/popular-routines/$routineId/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      print('❌ Error adding popular routine: $e');
      return false;
    }
  }

  /// Transform backend response to match expected format
  Map<String, dynamic> _transformRoutine(Map<String, dynamic> routine) {
    final habits = (routine['habits'] as List<dynamic>?)?.map((h) => {
      'name': h['name'],
      'emoji': h['emoji'] ?? '📌',
      'category': h['category'],
      'time': h['time'],
    }).toList() ?? [];

    return {
      'id': routine['id'],
      'name': routine['name'],
      'description': routine['description'],
      'emoji': routine['emoji'] ?? '📋',
      'habitCount': habits.length,
      'usersCount': routine['usersCount'] ?? 0,
      'categories': List<String>.from(routine['categories'] ?? []),
      'habits': habits,
    };
  }
}
