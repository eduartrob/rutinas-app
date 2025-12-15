import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';

/// Provider for managing app theme with persistence
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _isLoading = true;
  
  /// Current theme mode
  AppThemeMode get themeMode => _themeMode;
  
  /// Is still loading preferences
  bool get isLoading => _isLoading;
  
  /// Is dark theme active
  bool isDark(BuildContext context) {
    if (_themeMode == AppThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == AppThemeMode.dark;
  }
  
  /// Get current theme data
  ThemeData getThemeData(Brightness platformBrightness) {
    return AppThemes.getTheme(_themeMode, platformBrightness);
  }
  
  /// Get theme mode for MaterialApp
  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
  
  /// Initialize and load saved preferences
  Future<void> initialize() async {
    try {
      debugPrint('🎨 ThemeProvider: Loading preferences...');
      await _loadPreference();
      debugPrint('🎨 ThemeProvider: Loaded theme mode: ${_themeMode.label}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ ThemeProvider: Error loading preferences: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode != mode) {
      debugPrint('🎨 ThemeProvider: Changing from ${_themeMode.label} to ${mode.label}');
      _themeMode = mode;
      await _savePreference();
      notifyListeners();
      debugPrint('🎨 ThemeProvider: Theme changed successfully');
    }
  }
  
  /// Load saved preference
  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null && themeIndex < AppThemeMode.values.length) {
        _themeMode = AppThemeMode.values[themeIndex];
      }
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }
  
  /// Save preference
  Future<void> _savePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }
  
  /// Reset to default
  Future<void> resetToDefault() async {
    _themeMode = AppThemeMode.system;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeKey);
    } catch (e) {
      debugPrint('Error resetting theme preference: $e');
    }
    notifyListeners();
  }
}
