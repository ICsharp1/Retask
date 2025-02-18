import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/step.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/dialog_utils.dart';
import '../widgets/steps/step_item.dart';

class StepsScreen extends StatefulWidget {
  final Task task;

  const StepsScreen({super.key, required this.task});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  TaskStep _copyStepWithSubsteps(TaskStep step) {
    return TaskStep(
      title: step.title,
      isCompleted: step.isCompleted,
      isCurrent: step.isCurrent,
      isExpanded: step.isExpanded,
      subSteps: List.from(step.subSteps.map((s) => _copyStepWithSubsteps(s))),
      lastCurrentSubstep: step.lastCurrentSubstep != null ? _copyStepWithSubsteps(step.lastCurrentSubstep!) : null,
    );
  }

  void _addStep(TaskStep? parent) async {
    final titleController = TextEditingController();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    // Get the current version of the task
    final currentTask = taskProvider.tasks.firstWhere(
      (t) => t.title == widget.task.title && t.nextDue.isAtSameMomentAs(widget.task.nextDue),
      orElse: () => widget.task,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: size.width * 0.95,
              height: size.height * 0.7,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        parent != null ? 'Add Sub-step' : 'Add Step',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Write your step details here...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        autofocus: true,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        expands: true,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isNotEmpty) {
                            final newStep = TaskStep(
                              title: titleController.text.trim(),
                            );

                            // Add step through the provider using the current task
                            await taskProvider.addStepToTask(
                              currentTask,
                              newStep,
                              parent: parent,
                            );

                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _editStep(TaskStep step) {
    final titleController = TextEditingController(text: step.title);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: size.width * 0.95,
              height: size.height * 0.7,
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Step',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Write your step details here...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        autofocus: true,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        expands: true,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            setState(() {
                              step.title = titleController.text.trim();
                            });

                            final taskProvider = Provider.of<TaskProvider>(
                                context,
                                listen: false);
                            taskProvider.updateTask(
                                widget.task, widget.task.deepCopy());

                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteStep(TaskStep step) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Step'),
          content: const Text('Are you sure you want to delete this step?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (step.isCurrent) {
                    step.resetCurrentSteps();
                  }

                  // Find and remove the step from its parent list
                  bool removed = widget.task.steps.remove(step);
                  if (!removed) {
                    // If not found in root steps, search through all substeps
                    for (var rootStep in widget.task.steps) {
                      if (_removeStepFromSubsteps(rootStep.subSteps, step)) {
                        break;
                      }
                    }
                  }
                });

                final taskProvider =
                    Provider.of<TaskProvider>(context, listen: false);
                taskProvider.updateTask(widget.task, widget.task.deepCopy());

                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  bool _removeStepFromSubsteps(List<TaskStep> substeps, TaskStep targetStep) {
    if (substeps.remove(targetStep)) {
      return true;
    }

    for (var step in substeps) {
      if (_removeStepFromSubsteps(step.subSteps, targetStep)) {
        return true;
      }
    }

    return false;
  }

  void _selectStep(TaskStep step) {
    setState(() {
      if (step.isCurrent) {
        step.resetCurrentSteps();
      } else {
        widget.task.setCurrentStep(step);

        TaskStep? parent = widget.task.findParentOf(step);
        while (parent != null) {
          parent.isExpanded = true;
          parent = widget.task.findParentOf(parent);
        }
      }
    });

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.updateTask(widget.task, widget.task.deepCopy());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          // Find the current version of the task in the provider
          final currentTask = taskProvider.tasks.firstWhere(
            (t) => t.title == widget.task.title && t.nextDue.isAtSameMomentAs(widget.task.nextDue),
            orElse: () => widget.task,
          );
          
          return ListView.builder(
            itemCount: currentTask.steps.length,
            itemBuilder: (context, index) {
              return StepItem(
                step: currentTask.steps[index],
                parentList: currentTask.steps,
                indentation: 0,
                onStepSelected: _selectStep,
                onStepDeleted: _deleteStep,
                onStepEdited: _editStep,
                onStepAdded: _addStep,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addStep(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
