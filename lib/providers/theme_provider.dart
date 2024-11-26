import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class ThemeProvider with ChangeNotifier {
  final SharedPreferences prefs;
  late AppSettings _settings;
  bool _isDarkMode = false;

  ThemeProvider(this.prefs);

  Future<void> init() async {
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
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
      notesBackgroundColor: Color(prefs.getInt('notesBackgroundColor') ?? const Color(0xFF424242).value),
      notesCardBorderColor: Color(prefs.getInt('notesCardBorderColor') ?? Colors.grey.value),
      notesTextColor: Color(prefs.getInt('notesTextColor') ?? Colors.white.value),
      stepCardBorderColor: Color(prefs.getInt('stepCardBorderColor') ?? Colors.grey.value),
      enableDarkMode: prefs.getBool('enableDarkMode') ?? false,
      showCompletedTasks: prefs.getBool('showCompletedTasks') ?? false,
      showOverdueWarning: prefs.getBool('showOverdueWarning') ?? false,
      showNonTodayTasks: prefs.getBool('showNonTodayTasks') ?? true,
      defaultReminderTime: prefs.getInt('defaultReminderTime') ?? 9,
      defaultSortOrder: prefs.getString('defaultSortOrder') ?? 'dueDate',
    );
  }

  bool get isDarkMode => _isDarkMode;
  bool get isDark => _isDarkMode; 
  AppSettings get settings => _settings;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _settings = _settings.copyWith(enableDarkMode: _isDarkMode);
    await prefs.setBool('enableDarkMode', _isDarkMode);
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
    _settings = AppSettings();
    _isDarkMode = _settings.enableDarkMode;
    await prefs.clear();
    notifyListeners();
  }

  ThemeData get currentTheme {
    return ThemeData(
      brightness: _settings.enableDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: _settings.notesBackgroundColor,
      cardColor: _settings.notesBackgroundColor,
      colorScheme: ColorScheme(
        brightness: _settings.enableDarkMode ? Brightness.dark : Brightness.light,
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
      ),
    );
  }
}