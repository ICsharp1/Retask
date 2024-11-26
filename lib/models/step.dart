import 'package:flutter/material.dart';

class TaskStep {
  String title;
  String description;
  List<TaskStep> subSteps;
  bool isCurrent;
  bool isExpanded;
  bool isTextOnly;
  TaskStep? lastCurrentSubstep;

  TaskStep({
    required this.title,
    this.description = '',
    List<TaskStep>? subSteps,
    this.isCurrent = false,
    this.isExpanded = false,
    this.isTextOnly = false,
    this.lastCurrentSubstep,
  }) : this.subSteps = subSteps ?? [];

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'subSteps': subSteps.map((step) => step.toJson()).toList(),
      'isCurrent': isCurrent,
      'isExpanded': isExpanded,
      'isTextOnly': isTextOnly,
      'lastCurrentSubstep': lastCurrentSubstep?.toJson(),
    };
  }

  factory TaskStep.fromJson(Map<String, dynamic> json) {
    return TaskStep(
      title: json['title'],
      description: json['description'] ?? '',
      subSteps: (json['subSteps'] as List?)
          ?.map((step) => TaskStep.fromJson(step))
          .toList() ?? [],
      isCurrent: json['isCurrent'] ?? false,
      isExpanded: json['isExpanded'] ?? false,
      isTextOnly: json['isTextOnly'] ?? false,
      lastCurrentSubstep: json['lastCurrentSubstep'] != null
          ? TaskStep.fromJson(json['lastCurrentSubstep'])
          : null,
    );
  }

  // Helper method to find current step in the hierarchy
  TaskStep? findCurrentStep() {
    if (isCurrent) return this;
    for (var step in subSteps) {
      final current = step.findCurrentStep();
      if (current != null) return current;
    }
    return null;
  }

  // Helper method to unset current step in the hierarchy
  void unsetCurrentStep() {
    isCurrent = false;
    for (var step in subSteps) {
      step.unsetCurrentStep();
    }
  }
}
