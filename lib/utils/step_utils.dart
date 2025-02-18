import '../models/step.dart';

class StepUtils {
  static void clearCurrentStep(List<TaskStep> steps) {
    for (var step in steps) {
      if (step.isCurrent) {
        step.isCurrent = false;
      }
      if (step.subSteps.isNotEmpty) {
        clearCurrentStep(step.subSteps);
      }
    }
  }

  static TaskStep? findCurrentStep(List<TaskStep> steps) {
    for (var step in steps) {
      if (step.isCurrent) {
        return step;
      }
      if (step.subSteps.isNotEmpty) {
        final current = findCurrentStep(step.subSteps);
        if (current != null) {
          return current;
        }
      }
    }
    return null;
  }

  static void deleteStep(TaskStep step, List<TaskStep> parentList) {
    parentList.remove(step);
  }
}
