import 'package:flutter/material.dart';

class AppSettings {
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
} 