import 'package:flutter/material.dart';

class TextInputDialog extends StatelessWidget {
  final String title;
  final String initialText;
  final Function(String) onSave;

  const TextInputDialog({
    super.key,
    required this.title,
    this.initialText = '',
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController(text: initialText);
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
              title: Text(title),
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
                        onSave(controller.text);
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
  }
}
