import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'di/app_module.dart';

// Auth Providers
import 'features/auth/login/presentation/providers/login_provider.dart';
import 'features/auth/register/presentation/providers/register_provider.dart';
import 'features/auth/recovery_password/presentation/providers/recovery_password_provider.dart';

// Routines Provider
import 'features/routines/presentation/providers/routines_provider.dart';

// Auth Pages
import 'features/auth/login/presentation/pages/login_page.dart';

// Navigation
import 'features/shell/main_shell.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/auth/login/domain/entities/user_entity.dart';

// Weather Provider (existing)
import 'features/presentation/providers/weather_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appModule = AppModule();
    
    return MultiProvider(
      providers: [
        // Auth Providers
        ChangeNotifierProvider<LoginProvider>(
          create: (_) => appModule.loginProvider,
        ),
        ChangeNotifierProvider<RegisterProvider>(
          create: (_) => appModule.registerProvider,
        ),
        ChangeNotifierProvider<RecoveryPasswordProvider>(
          create: (_) => appModule.recoveryPasswordProvider,
        ),
        // Routines Provider
        ChangeNotifierProvider<RoutinesProvider>(
          create: (_) => appModule.routinesProvider,
        ),
        // Weather Provider (existing)
        ChangeNotifierProvider<WeatherNotifier>(
          create: (_) => appModule.weatherNotifier,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rob Store',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF4CAF50),
            secondary: const Color(0xFF64B5F6),
            surface: const Color(0xFF252537),
          ),
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF252537),
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper to handle auth state and navigation
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthenticated = false;
  bool _isNewUser = true;
  UserEntity? _user;

  void _onLoginSuccess(UserEntity user, bool isNewUser) {
    setState(() {
      _isAuthenticated = true;
      _isNewUser = isNewUser;
      _user = user;
    });
  }

  void _onOnboardingComplete() {
    setState(() {
      _isNewUser = false;
    });
  }

  void _onLogout() {
    setState(() {
      _isAuthenticated = false;
      _isNewUser = true;
      _user = null;
    });
    // Reset login provider state
    context.read<LoginProvider>().reset();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return LoginPageWrapper(onLoginSuccess: _onLoginSuccess);
    }

    if (_isNewUser && _user != null) {
      return OnboardingPage(
        user: _user!,
        onComplete: _onOnboardingComplete,
      );
    }

    return MainShell(onLogout: _onLogout);
  }
}

/// Login page wrapper to handle navigation after successful login
class LoginPageWrapper extends StatelessWidget {
  final void Function(UserEntity user, bool isNewUser) onLoginSuccess;

  const LoginPageWrapper({super.key, required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, provider, _) {
        // Listen for successful login
        if (provider.status == LoginStatus.success && provider.user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onLoginSuccess(provider.user!, true); // Assume new user for onboarding
          });
        }
        return const LoginPage();
      },
    );
  }
}