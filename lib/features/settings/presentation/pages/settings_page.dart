import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app/core/theme/theme_provider.dart';
import 'package:app/core/theme/app_themes.dart';

/// Settings page with theme selection
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme section
          const Text(
            'Apariencia',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          
          // Theme options
          Card(
            child: Column(
              children: AppThemeMode.values.map((mode) {
                final isSelected = themeProvider.themeMode == mode;
                return ListTile(
                  leading: Icon(
                    mode.icon,
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : null,
                  ),
                  title: Text(mode.label),
                  subtitle: _getSubtitle(mode),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => themeProvider.setThemeMode(mode),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Account section
          const Text(
            'Cuenta',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Editar perfil'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to edit profile
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notificaciones'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to notifications settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Privacidad'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to privacy settings
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // App info section
          const Text(
            'Información',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Versión'),
                  trailing: Text('1.0.0', style: TextStyle(color: Colors.grey)),
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Ayuda'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to help
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Términos y condiciones'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to terms
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget? _getSubtitle(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return const Text('Fondo blanco, ideal para el día');
      case AppThemeMode.dark:
        return const Text('Fondo oscuro, reduce fatiga visual');
      case AppThemeMode.system:
        return const Text('Sigue la configuración del dispositivo');
    }
  }
}
