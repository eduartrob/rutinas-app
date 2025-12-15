import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API configuration for easy deployment changes.
/// EC2 Server: 18.211.6.209:3000
class ApiConfig {
  /// Base URL for the backend API
  /// EC2 Production Server
  static String get baseApiUrl {
    return dotenv.env['BASE_API_URL'] ?? 'http://18.211.6.209:3000';
  }

  /// API version prefix
  static String get apiVersion => '/api';

  /// Full API base URL with version
  static String get apiUrl => '$baseApiUrl$apiVersion';

  // ============ AUTH ENDPOINTS ============
  
  /// POST - Login user
  static String get loginEndpoint => '$apiUrl/users/sign-in';
  
  /// POST - Register new user
  static String get registerEndpoint => '$apiUrl/users/sign-up';
  
  /// POST - Request password reset (sends email)
  static String get forgotPasswordEndpoint => '$apiUrl/users/forgot';
  
  /// POST - Verify reset code
  static String get verifyCodeEndpoint => '$apiUrl/users/verify-code';
  
  /// POST - Reset password with code
  static String get resetPasswordEndpoint => '$apiUrl/users/reset-password';
  
  /// POST - Validate token
  static String get validateTokenEndpoint => '$apiUrl/users/validate-token';
  
  /// POST - Logout
  static String get logoutEndpoint => '$apiUrl/users/logout';

  // ============ USER ENDPOINTS ============
  
  /// GET - Get all users
  static String get usersEndpoint => '$apiUrl/users/all';
  
  /// GET/DELETE - User by ID
  static String userByIdEndpoint(String id) => '$apiUrl/users/$id';
  
  /// PUT - Update user
  static String get updateUserEndpoint => '$apiUrl/users/update-user';

  // ============ ROUTINE ENDPOINTS ============
  
  /// GET - Get user's routines
  static String get routinesEndpoint => '$apiUrl/routines/';
  
  /// GET - Get single routine by ID
  static String routineByIdEndpoint(String id) => '$apiUrl/routines/$id';
  
  /// POST - Create routine
  static String get createRoutineEndpoint => '$apiUrl/routines/create';
  
  /// PUT - Update routine
  static String updateRoutineEndpoint(String id) => '$apiUrl/routines/update/$id';
  
  /// PUT - Toggle routine active status
  static String toggleRoutineEndpoint(String id) => '$apiUrl/routines/toggle/$id';
  
  /// DELETE - Delete routine
  static String deleteRoutineEndpoint(String id) => '$apiUrl/routines/delete/$id';

  // ============ PROGRESS ENDPOINTS ============
  
  /// POST - Toggle habit completion
  static String get toggleCompletionEndpoint => '$apiUrl/progress/toggle';
  
  /// GET - Get completions for a date
  static String get completionsEndpoint => '$apiUrl/progress/completions';
  
  /// GET - Get progress stats
  static String get progressStatsEndpoint => '$apiUrl/progress/stats';
}
