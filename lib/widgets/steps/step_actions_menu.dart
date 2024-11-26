import 'package:flutter/material.dart';

class StepActionsMenu extends StatelessWidget {
  final Function() onAddText;
  final Function() onAddStep;
  final Function() onEdit;
  final Function() onDelete;
  final Color? iconColor;

  const StepActionsMenu({
    super.key,
    required this.onAddText,
    required this.onAddStep,
    required this.onEdit,
    required this.onDelete,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: iconColor),
      onSelected: (value) {
        switch (value) {
          case 'text':
            onAddText();
            break;
          case 'step':
            onAddStep();
            break;
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'text',
          child: Row(
            children: [
              Icon(Icons.text_fields, color: iconColor),
              const SizedBox(width: 8),
              const Text('Add Text'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'step',
          child: Row(
            children: [
              Icon(Icons.list, color: iconColor),
              const SizedBox(width: 8),
              const Text('Add Step'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: iconColor),
              const SizedBox(width: 8),
              const Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: iconColor),
              const SizedBox(width: 8),
              const Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }
}
