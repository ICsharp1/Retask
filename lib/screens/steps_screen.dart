import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/step.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/dialog_utils.dart';
import '../utils/step_utils.dart';
import '../widgets/steps/step_item.dart';

class StepsScreen extends StatefulWidget {
  final Task task;

  const StepsScreen({super.key, required this.task});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  void _addText(TaskStep? parent) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: size.width,
            height: size.height * 0.8,
            color: Theme.of(context).dialogBackgroundColor,
            child: Column(
              children: [
                AppBar(
                  title: const Text('Add Text'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: controller,
                      maxLines: null,
                      expands: true,
                      autofocus: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your text...',
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            setState(() {
                              final newStep = TaskStep(
                                title: controller.text,
                                isTextOnly: true,
                              );
                              if (parent != null) {
                                parent.subSteps.add(newStep);
                              } else {
                                widget.task.steps.add(newStep);
                              }
                              Provider.of<TaskProvider>(context, listen: false)
                                  .saveTask(widget.task);
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addStep(TaskStep? parent) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Step'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  final newStep = TaskStep(
                    title: titleController.text,
                    description: descriptionController.text,
                    isTextOnly: false,
                  );
                  if (parent != null) {
                    parent.subSteps.add(newStep);
                  } else {
                    widget.task.steps.add(newStep);
                  }
                  Provider.of<TaskProvider>(context, listen: false).saveTask(widget.task);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editStep(TaskStep step) {
    DialogUtils.showTextInput(
      context: context,
      title: 'Edit Text',
      initialText: step.title,
      onSave: (text) {
        setState(() {
          step.title = text;
          Provider.of<TaskProvider>(context, listen: false).saveTask(widget.task);
        });
      },
    );
  }

  void _deleteStep(TaskStep step, {List<TaskStep>? parentList}) {
    DialogUtils.showConfirmation(
      context: context,
      title: 'Delete Step',
      message: 'Are you sure you want to delete this step?',
      onConfirm: () {
        setState(() {
          StepUtils.deleteStep(
            step,
            parentList ?? widget.task.steps,
          );
          Provider.of<TaskProvider>(context, listen: false).saveTask(widget.task);
        });
      },
    );
  }

  void _selectStep(TaskStep step) {
    setState(() {
      // Clear current from all steps
      _clearCurrentStep(widget.task.steps);
      // Set this step as current
      step.isCurrent = true;
      // Ensure all parent steps are expanded
      _expandParents(step, widget.task.steps);
    });
    Provider.of<TaskProvider>(context, listen: false).saveTask(widget.task);
  }

  void _clearCurrentStep(List<TaskStep> steps) {
    for (final step in steps) {
      step.isCurrent = false;
      _clearCurrentStep(step.subSteps);
    }
  }

  bool _expandParents(TaskStep targetStep, List<TaskStep> steps, [TaskStep? parent]) {
    for (final step in steps) {
      if (step == targetStep && parent != null) {
        parent.isExpanded = true;
        return true;
      }
      if (_expandParents(targetStep, step.subSteps, step)) {
        if (parent != null) {
          parent.isExpanded = true;
        }
        return true;
      }
    }
    return false;
  }

  void _showAddDialog({TaskStep? parent}) {
    DialogUtils.showAddOptions(
      context: context,
      onAddText: () => _addText(parent),
      onAddStep: () => _addStep(parent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddDialog(),
                tooltip: 'Add Step or Text',
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.task.steps.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final step = widget.task.steps[index];
          return StepItem(
            step: step,
            parentList: widget.task.steps,
            indentation: 0,
            onStepSelected: _selectStep,
            onStepDeleted: _deleteStep,
            onStepEdited: _editStep,
            onTextAdded: _addText,
            onStepAdded: _addStep,
          );
        },
      ),
    );
  }
}
