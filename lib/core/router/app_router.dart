import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'routes.dart';

// Core
import '../services/auth_token_service.dart';

// Auth Pages
import '../../features/auth/login/presentation/pages/login_page.dart';
import '../../features/auth/register/presentation/pages/register_page.dart';
import '../../features/auth/recovery_password/presentation/pages/forgot_password_page.dart';
import '../../features/auth/recovery_password/presentation/pages/verify_code_page.dart';
import '../../features/auth/recovery_password/presentation/pages/reset_password_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

// Main Pages
import '../../features/shell/main_shell.dart';
import '../../features/routines/presentation/pages/create_routine_page.dart';
import '../../features/routines/presentation/pages/routine_detail_page.dart';
import '../../features/routines/domain/entities/routine_entity.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/auth/login/domain/entities/user_entity.dart';

/// Main application router using GoRouter
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashPath,
  debugLogDiagnostics: true,
  redirect: (context, state) async {
    // Check authentication state
    final isLoggedIn = await AuthTokenService().isLoggedIn();
    final isAuthRoute = state.matchedLocation == AppRoutes.loginPath ||
        state.matchedLocation == AppRoutes.registerPath ||
        state.matchedLocation == AppRoutes.forgotPasswordPath ||
        state.matchedLocation == AppRoutes.verifyCodePath ||
        state.matchedLocation == AppRoutes.resetPasswordPath;
    final isSplash = state.matchedLocation == AppRoutes.splashPath;

    // Splash screen handles its own redirect
    if (isSplash) return null;

    // If not logged in and trying to access protected route
    if (!isLoggedIn && !isAuthRoute) {
      return AppRoutes.loginPath;
    }

    // If logged in and trying to access auth route
    if (isLoggedIn && isAuthRoute) {
      return AppRoutes.homePath;
    }

    return null;
  },
  routes: [
    // === SPLASH ===
    GoRoute(
      path: AppRoutes.splashPath,
      name: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // === AUTH ROUTES ===
    GoRoute(
      path: AppRoutes.loginPath,
      name: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.registerPath,
      name: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPasswordPath,
      name: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.verifyCodePath,
      name: AppRoutes.verifyCode,
      builder: (context, state) => const VerifyCodePage(),
    ),
    GoRoute(
      path: AppRoutes.resetPasswordPath,
      name: AppRoutes.resetPassword,
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.onboardingPath,
      name: AppRoutes.onboarding,
      builder: (context, state) {
        final user = state.extra as UserEntity?;
        return OnboardingPage(
          user: user ?? const UserEntity(id: '', name: '', email: ''),
          onComplete: () => context.go(AppRoutes.homePath),
        );
      },
    ),

    // === MAIN SHELL WITH BOTTOM NAV ===
    GoRoute(
      path: AppRoutes.homePath,
      name: AppRoutes.home,
      builder: (context, state) => MainShell(
        onLogout: () async {
          await AuthTokenService().clearAll();
          if (context.mounted) {
            context.go(AppRoutes.loginPath);
          }
        },
      ),
    ),

    // === ROUTINE ROUTES ===
    GoRoute(
      path: AppRoutes.createRoutinePath,
      name: AppRoutes.createRoutine,
      builder: (context, state) => const CreateRoutinePage(),
    ),
    GoRoute(
      path: AppRoutes.routineDetailPath,
      name: AppRoutes.routineDetail,
      builder: (context, state) {
        final routine = state.extra as RoutineEntity;
        return RoutineDetailPage(routine: routine);
      },
    ),
    GoRoute(
      path: AppRoutes.editRoutinePath,
      name: AppRoutes.editRoutine,
      builder: (context, state) {
        final routine = state.extra as RoutineEntity;
        return CreateRoutinePage(routine: routine);
      },
    ),

    // === SETTINGS ===
    GoRoute(
      path: AppRoutes.settingsPath,
      name: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
  ],

  // Error handling
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF1A1A2E),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Página no encontrada',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.homePath),
            child: const Text('Ir al inicio'),
          ),
        ],
      ),
    ),
  ),
);

/// Splash screen that checks auth and redirects
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash delay
    
    if (!mounted) return;

    final isLoggedIn = await AuthTokenService().isLoggedIn();
    
    if (!mounted) return;

    if (isLoggedIn) {
      context.go(AppRoutes.homePath);
    } else {
      context.go(AppRoutes.loginPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.checklist,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rutinas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Construye mejores hábitos',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Color(0xFF4CAF50)),
          ],
        ),
      ),
    );
  }
}
