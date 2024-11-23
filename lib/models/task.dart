import 'package:flutter/material.dart';

class Task {
  String title;
  int frequencyInDays;
  bool hasNotification;
  DateTime lastCompleted;
  DateTime nextDue;
  bool isCompleted = false;
  Color color;
  TimeOfDay? notificationTime;

  Task({
    required this.title,
    required this.frequencyInDays,
    this.hasNotification = false,
    required this.lastCompleted,
    required this.nextDue,
    this.color = Colors.blue,
    this.notificationTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'frequencyInDays': frequencyInDays,
      'hasNotification': hasNotification,
      'lastCompleted': lastCompleted.toIso8601String(),
      'nextDue': nextDue.toIso8601String(),
      'isCompleted': isCompleted,
      'color': color.value,
      'notificationTime': notificationTime != null 
          ? '${notificationTime!.hour}:${notificationTime!.minute}'
          : null,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      frequencyInDays: json['frequencyInDays'],
      hasNotification: json['hasNotification'],
      lastCompleted: DateTime.parse(json['lastCompleted']),
      nextDue: DateTime.parse(json['nextDue']),
      color: Color(json['color'] ?? Colors.blue.value),
      notificationTime: json['notificationTime'] != null 
          ? TimeOfDay(
              hour: int.parse((json['notificationTime'] as String).split(':')[0]),
              minute: int.parse((json['notificationTime'] as String).split(':')[1]),
            )
          : null,
    )..isCompleted = json['isCompleted'] ?? false;
  }
}
