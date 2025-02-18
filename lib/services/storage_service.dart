import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/app_settings.dart';

class StorageService {
  final SharedPreferences prefs;

  StorageService(this.prefs);

  Future<void> clearAllData() async {
    await prefs.clear();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final tasksJson = tasks.map((task) => task.toJson()).toList();
    await prefs.setString('tasks', jsonEncode(tasksJson));
  }

  Future<List<Task>> loadTasks() async {
    final tasksJson = prefs.getString('tasks');
    if (tasksJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(tasksJson);
    return decoded.map((json) => Task.fromJson(json)).toList();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await prefs.setInt('taskDueTodayColor', settings.taskDueTodayColor.value);
    await prefs.setInt('taskOverdueColor', settings.taskOverdueColor.value);
    await prefs.setInt('taskFutureColor', settings.taskFutureColor.value);
    await prefs.setInt('taskDueTodayTextColor', settings.taskDueTodayTextColor.value);
    await prefs.setInt('taskOverdueTextColor', settings.taskOverdueTextColor.value);
    await prefs.setInt('taskFutureTextColor', settings.taskFutureTextColor.value);
    await prefs.setInt('notesBackgroundColor', settings.notesBackgroundColor.value);
    await prefs.setInt('notesCardBorderColor', settings.notesCardBorderColor.value);
    await prefs.setInt('notesTextColor', settings.notesTextColor.value);
    await prefs.setInt('stepCardBorderColor', settings.stepCardBorderColor.value);
    await prefs.setBool('enableDarkMode', settings.enableDarkMode);
    await prefs.setBool('showCompletedTasks', settings.showCompletedTasks);
    await prefs.setBool('showOverdueWarning', settings.showOverdueWarning);
    await prefs.setBool('showNonTodayTasks', settings.showNonTodayTasks);
    await prefs.setInt('defaultReminderTime', settings.defaultReminderTime);
    await prefs.setString('defaultSortOrder', settings.defaultSortOrder);
  }

  Future<AppSettings> loadSettings() async {
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
}