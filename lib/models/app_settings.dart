import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppSettings {
  Color taskDueTodayColor;
  Color taskOverdueColor;
  Color taskFutureColor;
  Color taskDueTodayTextColor;
  Color taskOverdueTextColor;
  Color taskFutureTextColor;
  Color notesBackgroundColor;
  Color notesCardBorderColor;
  Color notesTextColor;
  Color stepCardBorderColor;
  Color currentStepColor;
  Color textColor;
  bool enableDarkMode;
  bool showCompletedTasks;
  bool showOverdueWarning;
  bool showNonTodayTasks;
  int defaultReminderTime;
  String defaultSortOrder;

  AppSettings({
    this.taskDueTodayColor = Colors.orange,
    this.taskOverdueColor = Colors.red,
    this.taskFutureColor = Colors.blue,
    this.taskDueTodayTextColor = Colors.white,
    this.taskOverdueTextColor = Colors.white,
    this.taskFutureTextColor = Colors.white,
    this.notesBackgroundColor = Colors.black,
    this.notesCardBorderColor = Colors.grey,
    this.notesTextColor = Colors.white,
    this.stepCardBorderColor = Colors.grey,
    this.currentStepColor = Colors.orange,
    this.textColor = Colors.white,
    this.enableDarkMode = true,
    this.showCompletedTasks = false,
    this.showOverdueWarning = false,
    this.showNonTodayTasks = true,
    this.defaultReminderTime = 9,
    this.defaultSortOrder = 'dueDate',
  });

  Map<String, dynamic> toJson() => {
        'taskDueTodayColor': taskDueTodayColor.value,
        'taskOverdueColor': taskOverdueColor.value,
        'taskFutureColor': taskFutureColor.value,
        'taskDueTodayTextColor': taskDueTodayTextColor.value,
        'taskOverdueTextColor': taskOverdueTextColor.value,
        'taskFutureTextColor': taskFutureTextColor.value,
        'notesBackgroundColor': notesBackgroundColor.value,
        'notesCardBorderColor': notesCardBorderColor.value,
        'notesTextColor': notesTextColor.value,
        'stepCardBorderColor': stepCardBorderColor.value,
        'currentStepColor': currentStepColor.value,
        'textColor': textColor.value,
        'enableDarkMode': enableDarkMode,
        'showCompletedTasks': showCompletedTasks,
        'showOverdueWarning': showOverdueWarning,
        'showNonTodayTasks': showNonTodayTasks,
        'defaultReminderTime': defaultReminderTime,
        'defaultSortOrder': defaultSortOrder,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      taskDueTodayColor: Color(json['taskDueTodayColor'] ?? Colors.orange.value),
      taskOverdueColor: Color(json['taskOverdueColor'] ?? Colors.red.value),
      taskFutureColor: Color(json['taskFutureColor'] ?? Colors.blue.value),
      taskDueTodayTextColor: Color(json['taskDueTodayTextColor'] ?? Colors.white.value),
      taskOverdueTextColor: Color(json['taskOverdueTextColor'] ?? Colors.white.value),
      taskFutureTextColor: Color(json['taskFutureTextColor'] ?? Colors.white.value),
      notesBackgroundColor: Color(json['notesBackgroundColor'] ?? Colors.black.value),
      notesCardBorderColor: Color(json['notesCardBorderColor'] ?? Colors.grey.value),
      notesTextColor: Color(json['notesTextColor'] ?? Colors.white.value),
      stepCardBorderColor: Color(json['stepCardBorderColor'] ?? Colors.grey.value),
      currentStepColor: Color(json['currentStepColor'] ?? Colors.orange.value),
      textColor: Color(json['textColor'] ?? Colors.white.value),
      enableDarkMode: json['enableDarkMode'] ?? false,
      showCompletedTasks: json['showCompletedTasks'] ?? false,
      showOverdueWarning: json['showOverdueWarning'] ?? false,
      showNonTodayTasks: json['showNonTodayTasks'] ?? true,
      defaultReminderTime: json['defaultReminderTime'] ?? 9,
      defaultSortOrder: json['defaultSortOrder'] ?? 'dueDate',
    );
  }

  AppSettings copyWith({
    Color? taskDueTodayColor,
    Color? taskOverdueColor,
    Color? taskFutureColor,
    Color? taskDueTodayTextColor,
    Color? taskOverdueTextColor,
    Color? taskFutureTextColor,
    Color? notesBackgroundColor,
    Color? notesCardBorderColor,
    Color? notesTextColor,
    Color? stepCardBorderColor,
    Color? currentStepColor,
    Color? textColor,
    bool? enableDarkMode,
    bool? showCompletedTasks,
    bool? showOverdueWarning,
    bool? showNonTodayTasks,
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
      notesBackgroundColor: notesBackgroundColor ?? this.notesBackgroundColor,
      notesCardBorderColor: notesCardBorderColor ?? this.notesCardBorderColor,
      notesTextColor: notesTextColor ?? this.notesTextColor,
      stepCardBorderColor: stepCardBorderColor ?? this.stepCardBorderColor,
      currentStepColor: currentStepColor ?? this.currentStepColor,
      textColor: textColor ?? this.textColor,
      enableDarkMode: enableDarkMode ?? this.enableDarkMode,
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      showOverdueWarning: showOverdueWarning ?? this.showOverdueWarning,
      showNonTodayTasks: showNonTodayTasks ?? this.showNonTodayTasks,
      defaultReminderTime: defaultReminderTime ?? this.defaultReminderTime,
      defaultSortOrder: defaultSortOrder ?? this.defaultSortOrder,
    );
  }
}