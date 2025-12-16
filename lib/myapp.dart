import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'di/app_module.dart';

// Core - Router
import 'core/router/app_router.dart';

// Core - Theme
import 'core/theme/theme_provider.dart';
import 'core/theme/app_themes.dart';

// Auth Providers
import 'features/auth/login/presentation/providers/login_provider.dart';
import 'features/auth/register/presentation/providers/register_provider.dart';
import 'features/auth/recovery_password/presentation/providers/recovery_password_provider.dart';

// Routines Provider
import 'features/routines/presentation/providers/routines_provider.dart';

// Progress Provider
import 'features/progress/presentation/providers/progress_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appModule = AppModule();
    
    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) {
            final provider = ThemeProvider();
            provider.initialize();
            return provider;
          },
        ),
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
        // Progress Provider
        ChangeNotifierProvider<ProgressProvider>(
          create: (_) => appModule.progressProvider,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Rutinas',
            
            // Theme configuration
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.materialThemeMode,
            
            // GoRouter configuration
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}