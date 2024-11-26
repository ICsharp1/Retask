import 'package:flutter/material.dart';
import 'step.dart';

class Task {
  String title;
  int frequencyInDays;
  bool hasNotification;
  DateTime lastCompleted;
  DateTime nextDue;
  bool isCompleted;
  Color color;
  TimeOfDay? notificationTime;
  List<TaskStep> steps;

  Task({
    required this.title,
    required this.frequencyInDays,
    this.hasNotification = false,
    required this.lastCompleted,
    required this.nextDue,
    this.isCompleted = false,
    this.color = Colors.blue,
    TimeOfDay? notificationTime,
    List<TaskStep>? steps,
  }) : this.notificationTime = notificationTime ?? const TimeOfDay(hour: 10, minute: 0),
       this.steps = steps ?? [];

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
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      frequencyInDays: json['frequencyInDays'],
      hasNotification: json['hasNotification'],
      lastCompleted: DateTime.parse(json['lastCompleted']),
      nextDue: DateTime.parse(json['nextDue']),
      isCompleted: json['isCompleted'] ?? false,
      color: Color(json['color'] ?? Colors.blue.value),
      notificationTime: json['notificationTime'] != null 
          ? TimeOfDay(
              hour: int.parse((json['notificationTime'] as String).split(':')[0]),
              minute: int.parse((json['notificationTime'] as String).split(':')[1]),
            )
          : null,
      steps: (json['steps'] as List?)
          ?.map((step) => TaskStep.fromJson(step))
          .toList() ?? [],
    );
  }

  TaskStep? get currentStep {
    for (var step in steps) {
      final current = step.findCurrentStep();
      if (current != null) return current;
    }
    return null;
  }

  void setCurrentStep(TaskStep newCurrentStep) {
    // First, unset the current step in the entire hierarchy
    for (var step in steps) {
      step.unsetCurrentStep();
    }
    // Set the new current step
    newCurrentStep.isCurrent = true;
  }
}
