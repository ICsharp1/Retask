import 'package:flutter/material.dart';

class TaskStep {
  final String id;
  String title;
  List<TaskStep> subSteps;
  bool isCurrent;
  bool isExpanded;
  bool isCompleted;
  TaskStep? lastCurrentSubstep;

  TaskStep({
    String? id,
    required this.title,
    List<TaskStep>? subSteps,
    this.isCurrent = false,
    this.isExpanded = false,
    this.isCompleted = false,
    this.lastCurrentSubstep,
  }) : this.id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       this.subSteps = subSteps ?? [];

  TaskStep copyWith({
    String? id,
    String? title,
    List<TaskStep>? subSteps,
    bool? isCurrent,
    bool? isExpanded,
    bool? isCompleted,
    TaskStep? lastCurrentSubstep,
  }) {
    return TaskStep(
      id: id ?? this.id,
      title: title ?? this.title,
      subSteps: subSteps ?? List.from(this.subSteps.map((step) => step.copyWith()).toList()),
      isCurrent: isCurrent ?? this.isCurrent,
      isExpanded: isExpanded ?? this.isExpanded,
      isCompleted: isCompleted ?? this.isCompleted,
      lastCurrentSubstep: lastCurrentSubstep ?? this.lastCurrentSubstep?.copyWith(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subSteps': subSteps.map((step) => step.toJson()).toList(),
      'isCurrent': isCurrent,
      'isExpanded': isExpanded,
      'isCompleted': isCompleted,
      'lastCurrentSubstep': lastCurrentSubstep?.toJson(),
    };
  }

  factory TaskStep.fromJson(Map<String, dynamic> json) {
    return TaskStep(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'],
      subSteps: (json['subSteps'] as List?)
          ?.map((step) => TaskStep.fromJson(step as Map<String, dynamic>))
          .toList() ??
          [],
      isCurrent: json['isCurrent'] ?? false,
      isExpanded: json['isExpanded'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      lastCurrentSubstep: json['lastCurrentSubstep'] != null
          ? TaskStep.fromJson(json['lastCurrentSubstep'] as Map<String, dynamic>)
          : null,
    );
  }

  TaskStep? findCurrentStep() {
    if (isCurrent) return this;
    for (var step in subSteps) {
      final current = step.findCurrentStep();
      if (current != null) return current;
    }
    return null;
  }

  void resetCurrentSteps() {
    isCurrent = false;
    lastCurrentSubstep = null;
    for (var step in subSteps) {
      step.resetCurrentSteps();
    }
  }
}
