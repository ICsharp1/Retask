import 'package:flutter/material.dart';

class AddOptionsDialog extends StatelessWidget {
  final Function() onAddText;
  final Function() onAddStep;

  const AddOptionsDialog({
    super.key,
    required this.onAddText,
    required this.onAddStep,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to Step'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Add Text'),
            onTap: () {
              Navigator.pop(context);
              onAddText();
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Add Step'),
            onTap: () {
              Navigator.pop(context);
              onAddStep();
            },
          ),
        ],
      ),
    );
  }
}
