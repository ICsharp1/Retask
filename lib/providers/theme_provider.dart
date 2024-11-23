import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';

class AppSettings {
  static const defaultTaskDueTodayColor = Color.fromARGB(255, 125, 12, 218);
  static const defaultTaskOverdueColor = Color.fromARGB(255, 255, 17, 0);
  static const defaultTaskFutureColor = Color.fromARGB(255, 3, 136, 244);
  Color taskDueTodayColor;
  Color taskOverdueColor;
  Color taskFutureColor;
  Color taskDueTodayTextColor;
  Color taskOverdueTextColor;
  Color taskFutureTextColor;
  bool enableDarkMode;
  bool showCompletedTasks;
  int defaultReminderTime;
  String defaultSortOrder;

  AppSettings({
    required this.taskDueTodayColor,
    required this.taskOverdueColor,
    required this.taskFutureColor,
    required this.taskDueTodayTextColor,
    required this.taskOverdueTextColor,
    required this.taskFutureTextColor,
    required this.enableDarkMode,
    required this.showCompletedTasks,
    required this.defaultReminderTime,
    required this.defaultSortOrder,
  });

  AppSettings copyWith({
    Color? taskDueTodayColor,
    Color? taskOverdueColor,
    Color? taskFutureColor,
    Color? taskDueTodayTextColor,
    Color? taskOverdueTextColor,
    Color? taskFutureTextColor,
    bool? enableDarkMode,
    bool? showCompletedTasks,
    int? defaultReminderTime,
    String? defaultSortOrder,
  }) {
    return AppSettings(
      taskDueTodayColor: taskDueTodayColor ?? this.taskDueTodayColor,
      taskOverdueColor: taskOverdueColor ?? this.taskOverdueColor,
      taskFutureColor: taskFutureColor ?? this.taskFutureColor,
      taskDueTodayTextColor: taskDueTodayTextColor ?? this.taskDueTodayTextColor,
      taskOverdueTextColor: taskOverdueTextColor ?? this.taskOverdueTextColor,
      taskFutureTextColor: taskFutureTextColor ?? this.taskFutureTextColor,
      enableDarkMode: enableDarkMode ?? this.enableDarkMode,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      defaultReminderTime: defaultReminderTime ?? this.defaultReminderTime,
      defaultSortOrder: defaultSortOrder ?? this.defaultSortOrder,
    );
  }
}

class ThemeProvider with ChangeNotifier {
  final SharedPreferences prefs;
  late AppSettings _settings;

  ThemeProvider(this.prefs) {
    _settings = AppSettings(
      taskDueTodayColor: Color(prefs.getInt('taskDueTodayColor') ?? AppSettings.defaultTaskDueTodayColor.value),
      taskOverdueColor: Color(prefs.getInt('taskOverdueColor') ?? AppSettings.defaultTaskOverdueColor.value),
      taskFutureColor: Color(prefs.getInt('taskFutureColor') ?? AppSettings.defaultTaskFutureColor.value),
      taskDueTodayTextColor: Color(prefs.getInt('taskDueTodayTextColor') ?? Colors.white.value),
      taskOverdueTextColor: Color(prefs.getInt('taskOverdueTextColor') ?? Colors.white.value),
      taskFutureTextColor: Color(prefs.getInt('taskFutureTextColor') ?? Colors.white.value),
      enableDarkMode: prefs.getBool('isDarkMode') ?? true,
      showCompletedTasks: prefs.getBool('showCompletedTasks') ?? true,
      defaultReminderTime: prefs.getInt('defaultReminderTime') ?? 30,
      defaultSortOrder: prefs.getString('defaultSortOrder') ?? 'dueDate',
    );
  }

  AppSettings get settings => _settings;
  set settings(AppSettings value) => _settings = value;
  bool get isDarkMode => _settings.enableDarkMode;

  ThemeData get theme => _settings.enableDarkMode ? _darkTheme : _lightTheme;

  final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color.fromARGB(255, 30, 30, 30),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 40, 40, 40),
    ),
  );

  final _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
  );

  Color get cardColor => isDarkMode ? Colors.grey[800]! : Colors.white;
  Color get cardTextColor => isDarkMode ? Colors.white : Colors.black;

  void toggleTheme() {
    _settings.enableDarkMode = !_settings.enableDarkMode;
    prefs.setBool('isDarkMode', _settings.enableDarkMode);
    notifyListeners();
  }

  void updateTaskColor(String colorType, Color color, BuildContext context) async {
    // Get current tasks that match the color type
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final tasks = taskProvider.tasks.where((task) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      switch (colorType) {
        case 'dueToday':
          return task.nextDue.day == today.day && !task.isCompleted;
        case 'overdue':
          return task.nextDue.isBefore(today) && !task.isCompleted;
        case 'future':
          return task.nextDue.isAfter(today) && !task.isCompleted;
        default:
          return false;
      }
    }).toList();

    // Update theme setting
    switch (colorType) {
      case 'dueToday':
        _settings.taskDueTodayColor = color;
        prefs.setInt('taskDueTodayColor', color.value);
      case 'overdue':
        _settings.taskOverdueColor = color;
        prefs.setInt('taskOverdueColor', color.value);
      case 'future':
        _settings.taskFutureColor = color;
        prefs.setInt('taskFutureColor', color.value);
    }
    notifyListeners();
  }

  void toggleShowCompletedTasks(bool value) {
    settings.showCompletedTasks = value;
    notifyListeners();
  }

  void setCardColor(String type, Color color) {
    switch (type) {
      case 'overdue':
        _settings.taskOverdueColor = color;
        prefs.setInt('taskOverdueColor', color.value);
      case 'dueToday':
        _settings.taskDueTodayColor = color;
        prefs.setInt('taskDueTodayColor', color.value);
      case 'future':
        _settings.taskFutureColor = color;
        prefs.setInt('taskFutureColor', color.value);
    }
    notifyListeners();
  }

  void setDefaultReminderTime(int minutes) {
    _settings.defaultReminderTime = minutes;
    prefs.setInt('defaultReminderTime', minutes);
    notifyListeners();
  }

  void setTaskDueTodayColor(Color color) {
    settings = settings.copyWith(taskDueTodayColor: color);
    notifyListeners();
  }

  void setTaskOverdueColor(Color color) {
    settings = settings.copyWith(taskOverdueColor: color);
    notifyListeners();
  }

  void setTaskFutureColor(Color color) {
    settings = settings.copyWith(taskFutureColor: color);
    notifyListeners();
  }

  void resetSettings() {
    _settings = AppSettings(
      taskDueTodayColor: Colors.orange,
      taskOverdueColor: Colors.red,
      taskFutureColor: Colors.blue,
      taskDueTodayTextColor: Colors.white,
      taskOverdueTextColor: Colors.white,
      taskFutureTextColor: Colors.white,
      enableDarkMode: true,
      showCompletedTasks: true,
      defaultReminderTime: 30,
      defaultSortOrder: 'dueDate',
    );
    
    // Save reset values to SharedPreferences
    prefs.setInt('taskDueTodayColor', Colors.orange.value);
    prefs.setInt('taskOverdueColor', Colors.red.value);
    prefs.setInt('taskFutureColor', Colors.blue.value);
    prefs.setInt('defaultReminderTime', 30);
    
    notifyListeners();
  }

  void resetColors() {
    _settings.taskDueTodayColor = AppSettings.defaultTaskDueTodayColor;
    _settings.taskOverdueColor = AppSettings.defaultTaskOverdueColor;
    _settings.taskFutureColor = AppSettings.defaultTaskFutureColor;
    
    prefs.setInt('taskDueTodayColor', AppSettings.defaultTaskDueTodayColor.value);
    prefs.setInt('taskOverdueColor', AppSettings.defaultTaskOverdueColor.value);
    prefs.setInt('taskFutureColor', AppSettings.defaultTaskFutureColor.value);
    
    notifyListeners();
  }
} 