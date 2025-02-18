import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../theme/app_themes.dart';

class ThemeProvider with ChangeNotifier {
  final SharedPreferences prefs;
  late AppSettings _settings;
  bool _isDarkMode = false;

  ThemeProvider(this.prefs);

  Future<void> init() async {
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    _settings = await _loadSettings();
    notifyListeners();
  }

  Future<AppSettings> _loadSettings() async {
    return AppSettings(
      taskDueTodayColor: Color(prefs.getInt('taskDueTodayColor') ?? Colors.orange.value),
      taskOverdueColor: Color(prefs.getInt('taskOverdueColor') ?? Colors.red.value),
      taskFutureColor: Color(prefs.getInt('taskFutureColor') ?? Colors.blue.value),
      taskDueTodayTextColor: Color(prefs.getInt('taskDueTodayTextColor') ?? Colors.white.value),
      taskOverdueTextColor: Color(prefs.getInt('taskOverdueTextColor') ?? Colors.white.value),
      taskFutureTextColor: Color(prefs.getInt('taskFutureTextColor') ?? Colors.white.value),
      notesBackgroundColor: Color(prefs.getInt('notesBackgroundColor') ?? 
        (_isDarkMode ? Colors.black.value : Colors.white.value)),
      notesCardBorderColor: Color(prefs.getInt('notesCardBorderColor') ?? 
        (_isDarkMode ? Colors.grey.value : Colors.grey[300]!.value)),
      notesTextColor: Color(prefs.getInt('notesTextColor') ?? 
        (_isDarkMode ? Colors.white.value : Colors.black87.value)),
      stepCardBorderColor: Color(prefs.getInt('stepCardBorderColor') ?? 
        (_isDarkMode ? Colors.grey.value : Colors.grey[300]!.value)),
      currentStepColor: Color(prefs.getInt('currentStepColor') ?? Colors.orange.value),
      textColor: Color(prefs.getInt('textColor') ?? 
        (_isDarkMode ? Colors.white.value : Colors.black87.value)),
      enableDarkMode: _isDarkMode,
      showCompletedTasks: prefs.getBool('showCompletedTasks') ?? false,
      showOverdueWarning: prefs.getBool('showOverdueWarning') ?? false,
      showNonTodayTasks: prefs.getBool('showNonTodayTasks') ?? true,
      defaultReminderTime: prefs.getInt('defaultReminderTime') ?? 10,
      defaultSortOrder: prefs.getString('defaultSortOrder') ?? 'dueDate',
    );
  }

  bool get isDarkMode => _isDarkMode;
  bool get isDark => _isDarkMode; 
  AppSettings get settings => _settings;
  ThemeData get theme => _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _settings = await _loadSettings(); // Reload settings with new theme colors
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleShowCompletedTasks(bool value) async {
    _settings = _settings.copyWith(showCompletedTasks: value);
    await prefs.setBool('showCompletedTasks', value);
    notifyListeners();
  }

  Future<void> toggleShowOverdueWarning(bool value) async {
    _settings = _settings.copyWith(showOverdueWarning: value);
    await prefs.setBool('showOverdueWarning', value);
    notifyListeners();
  }

  Future<void> toggleShowNonTodayTasks(bool value) async {
    _settings = _settings.copyWith(showNonTodayTasks: value);
    await prefs.setBool('showNonTodayTasks', value);
    notifyListeners();
  }

  Future<void> setDefaultReminderTime(int minutes) async {
    _settings = _settings.copyWith(defaultReminderTime: minutes);
    await prefs.setInt('defaultReminderTime', minutes);
    notifyListeners();
  }

  Future<void> setTaskDueTodayColor(Color color) async {
    _settings = _settings.copyWith(taskDueTodayColor: color);
    await prefs.setInt('taskDueTodayColor', color.value);
    notifyListeners();
  }

  Future<void> setTaskOverdueColor(Color color) async {
    _settings = _settings.copyWith(taskOverdueColor: color);
    await prefs.setInt('taskOverdueColor', color.value);
    notifyListeners();
  }

  Future<void> setTaskFutureColor(Color color) async {
    _settings = _settings.copyWith(taskFutureColor: color);
    await prefs.setInt('taskFutureColor', color.value);
    notifyListeners();
  }

  Future<void> setStepCardBorderColor(Color color) async {
    _settings = _settings.copyWith(stepCardBorderColor: color);
    await prefs.setInt('stepCardBorderColor', color.value);
    notifyListeners();
  }

  Future<void> setNotesBackgroundColor(Color color) async {
    _settings = _settings.copyWith(notesBackgroundColor: color);
    await prefs.setInt('notesBackgroundColor', color.value);
    notifyListeners();
  }

  Future<void> setNotesCardBorderColor(Color color) async {
    _settings = _settings.copyWith(notesCardBorderColor: color);
    await prefs.setInt('notesCardBorderColor', color.value);
    notifyListeners();
  }

  Future<void> setNotesTextColor(Color color) async {
    _settings = _settings.copyWith(notesTextColor: color);
    await prefs.setInt('notesTextColor', color.value);
    notifyListeners();
  }

  Future<void> resetColors() async {
    _settings = _settings.copyWith(
      taskDueTodayColor: Colors.orange,
      taskOverdueColor: Colors.red,
      taskFutureColor: Colors.blue,
      taskDueTodayTextColor: Colors.white,
      taskOverdueTextColor: Colors.white,
      taskFutureTextColor: Colors.white,
      notesBackgroundColor: const Color(0xFF424242),
      notesCardBorderColor: Colors.grey,
      notesTextColor: Colors.white,
      stepCardBorderColor: Colors.grey,
    );
    await prefs.setInt('notesBackgroundColor', _settings.notesBackgroundColor.value);
    await prefs.setInt('notesTextColor', _settings.notesTextColor.value);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    _isDarkMode = true;  // Reset to default dark mode
    await prefs.clear();  // Clear all settings
    
    // Reload settings with defaults
    _settings = await _loadSettings();
    
    // Save the dark mode setting
    await prefs.setBool('isDarkMode', _isDarkMode);
    
    notifyListeners();
  }

  ThemeData get currentTheme {
    final isDark = _settings.enableDarkMode;
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: _settings.notesBackgroundColor,
      cardColor: _settings.notesBackgroundColor,
      dialogBackgroundColor: _settings.notesBackgroundColor,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: _settings.taskDueTodayColor,
        onPrimary: _settings.taskDueTodayTextColor,
        secondary: _settings.taskFutureColor,
        onSecondary: _settings.taskFutureTextColor,
        error: _settings.taskOverdueColor,
        onError: _settings.taskOverdueTextColor,
        background: _settings.notesBackgroundColor,
        onBackground: _settings.notesTextColor,
        surface: _settings.notesBackgroundColor,
        onSurface: _settings.notesTextColor,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: _settings.notesTextColor),
        bodyMedium: TextStyle(color: _settings.notesTextColor),
        titleLarge: TextStyle(color: _settings.notesTextColor),
        titleMedium: TextStyle(color: _settings.notesTextColor),
        titleSmall: TextStyle(color: _settings.notesTextColor),
      ).apply(
        bodyColor: _settings.notesTextColor,
        displayColor: _settings.notesTextColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: _settings.notesTextColor.withOpacity(0.6)),
        labelStyle: TextStyle(color: _settings.notesTextColor),
      ),
      iconTheme: IconThemeData(
        color: _settings.notesTextColor,
      ),
    );
  }
}