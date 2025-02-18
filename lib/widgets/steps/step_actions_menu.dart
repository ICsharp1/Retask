import 'package:flutter/material.dart';
import '../../models/step.dart';

class StepActionsMenu extends StatelessWidget {
  final TaskStep step;
  final List<TaskStep>? parentList;
  final Function(TaskStep) onStepEdited;
  final Function(TaskStep) onStepDeleted;
  final Function(TaskStep) onStepAdded;

  const StepActionsMenu({
    super.key,
    required this.step,
    this.parentList,
    required this.onStepEdited,
    required this.onStepDeleted,
    required this.onStepAdded,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String value) {
        switch (value) {
          case 'edit':
            onStepEdited(step);
            break;
          case 'delete':
            onStepDeleted(step);
            break;
          case 'add':
            onStepAdded(step);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'add',
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text('Add Step'),
          ),
        ),
      ],
    );
  }
}
