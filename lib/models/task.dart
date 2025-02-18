import 'package:flutter/material.dart';
import 'step.dart';

class Task {
  final String title;
  final int frequencyInDays;
  final bool hasNotification;
  DateTime lastCompleted;
  DateTime nextDue;
  bool isCompleted;
  Color color;
  final TimeOfDay? notificationTime;
  final List<TaskStep> steps;

  Task({
    required this.title,
    required this.frequencyInDays,
    this.hasNotification = false,
    required this.lastCompleted,
    required this.nextDue,
    this.isCompleted = false,
    this.color = Colors.blue,
    this.notificationTime,
    List<TaskStep>? steps,
  })  : assert(frequencyInDays > 0, 'Frequency must be positive'),
        assert(!lastCompleted.isAfter(nextDue), 'Last completed date must be before or equal to next due date'),
        this.steps = steps?.toList() ?? [];

  Task deepCopy() {
    return Task(
      title: title,
      frequencyInDays: frequencyInDays,
      hasNotification: hasNotification,
      lastCompleted: lastCompleted,
      nextDue: nextDue,
      isCompleted: isCompleted,
      color: color,
      notificationTime: notificationTime,
      steps: steps.map((step) => step.copyWith()).toList(),
    );
  }

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
    try {
      final lastCompleted = DateTime.parse(json['lastCompleted'] as String);
      final nextDue = DateTime.parse(json['nextDue'] as String);
      
      return Task(
        title: json['title'] as String,
        frequencyInDays: json['frequencyInDays'] as int,
        hasNotification: json['hasNotification'] as bool? ?? false,
        lastCompleted: lastCompleted,
        nextDue: nextDue,
        isCompleted: json['isCompleted'] as bool? ?? false,
        color: Color(json['color'] as int? ?? Colors.blue.value),
        notificationTime: json['notificationTime'] != null
            ? TimeOfDay(
                hour: int.parse((json['notificationTime'] as String).split(':')[0]),
                minute: int.parse((json['notificationTime'] as String).split(':')[1]),
              )
            : null,
        steps: (json['steps'] as List?)
                ?.map((step) => TaskStep.fromJson(step as Map<String, dynamic>))
                .toList() ??
            [],
      );
    } catch (e) {
      throw FormatException('Invalid JSON format for Task: $e');
    }
  }

  TaskStep? get currentStep {
    for (var step in steps) {
      final current = step.findCurrentStep();
      if (current != null) return current;
    }
    return null;
  }

  void setCurrentStep(TaskStep newCurrentStep) {
    // Validate that the new step exists in the task's hierarchy
    final (foundStep, _) = findStepAndHierarchy(steps, newCurrentStep, []);
    if (foundStep == null) {
      throw ArgumentError('The provided step does not exist in this task\'s hierarchy');
    }

    // Find current step and its hierarchy
    TaskStep? oldCurrentStep;
    List<TaskStep> oldHierarchy = [];

    for (var step in steps) {
      final current = step.findCurrentStep();
      if (current != null) {
        oldCurrentStep = current;
        final (_, hierarchy) = findStepAndHierarchy(steps, current, []);
        oldHierarchy = hierarchy;
        break;
      }
    }

    // Find new step's hierarchy
    final (_, newHierarchy) = findStepAndHierarchy(steps, newCurrentStep, []);

    // Reset all current steps
    for (var step in steps) {
      step.resetCurrentSteps();
    }

    // Set the new current step
    newCurrentStep.isCurrent = true;

    // Update lastCurrentSubstep in the hierarchy if there is any
    if (newHierarchy.isNotEmpty) {
      for (int i = 0; i < newHierarchy.length; i++) {
        final parent = newHierarchy[i];
        final child =
            i == newHierarchy.length - 1 ? newCurrentStep : newHierarchy[i + 1];
        parent.lastCurrentSubstep = child;
      }
    }
  }

  (TaskStep?, List<TaskStep>) findStepAndHierarchy(
      List<TaskStep> steps, TaskStep target, List<TaskStep> currentPath) {
    for (var step in steps) {
      if (step == target) {
        return (step, List.from(currentPath));
      }
      currentPath.add(step);
      if (step.subSteps.isNotEmpty) {
        final (found, hierarchy) =
            findStepAndHierarchy(step.subSteps, target, currentPath);
        if (found != null) {
          return (found, hierarchy);
        }
      }
      currentPath.removeLast();
    }
    return (null, []);
  }

  TaskStep? findParentOf(TaskStep target) {
    return _searchInList(steps, target);
  }

  // Moved outside of findParentOf for better maintainability
  static TaskStep? _searchInList(List<TaskStep> steps, TaskStep target) {
    for (var step in steps) {
      // Check direct children
      if (step.subSteps.contains(target)) {
        return step;
      }
      // Check deeper levels
      final parent = _searchInList(step.subSteps, target);
      if (parent != null) {
        return parent;
      }
    }
    return null;
  }
}
