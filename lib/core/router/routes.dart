/// Application route names and paths
class AppRoutes {
  // === AUTH ROUTES ===
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String verifyCode = 'verify-code';
  static const String resetPassword = 'reset-password';
  static const String onboarding = 'onboarding';

  // === MAIN ROUTES ===
  static const String home = 'home';
  static const String routines = 'routines';
  static const String stats = 'stats';
  static const String profile = 'profile';

  // === SECONDARY ROUTES ===
  static const String createRoutine = 'create-routine';
  static const String editRoutine = 'edit-routine';
  static const String routineDetail = 'routine-detail';
  static const String settings = 'settings';

  // === AUTH PATHS ===
  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String verifyCodePath = '/verify-code';
  static const String resetPasswordPath = '/reset-password';
  static const String onboardingPath = '/onboarding';

  // === MAIN PATHS ===
  static const String homePath = '/home';
  static const String routinesPath = '/routines';
  static const String statsPath = '/stats';
  static const String profilePath = '/profile';

  // === SECONDARY PATHS ===
  static const String createRoutinePath = '/routines/create';
  static const String editRoutinePath = '/routines/edit/:id';
  static const String routineDetailPath = '/routines/:id';
  static const String settingsPath = '/settings';

  // === HELPER METHODS ===
  static String getRoutineDetailPath(String id) => '/routines/$id';
  static String getEditRoutinePath(String id) => '/routines/edit/$id';
}
