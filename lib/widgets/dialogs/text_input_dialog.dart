import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextInputDialog extends StatefulWidget {
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
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();

    // Set cursor to end of text
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      } else if (event.logicalKey == LogicalKeyboardKey.enter && 
                 event.isMetaPressed) {  // Cmd/Ctrl + Enter
        _saveAndPop();
      }
    }
  }

  void _saveAndPop() {
    if (_controller.text.isNotEmpty) {
      widget.onSave(_controller.text);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
              title: Text(widget.title),
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
                child: KeyboardListener(
                  focusNode: _focusNode,
                  onKeyEvent: (event) {
                    // Handle backspace explicitly
                    if (event is KeyDownEvent && 
                        event.logicalKey == LogicalKeyboardKey.backspace) {
                      final text = _controller.text;
                      final selection = _controller.selection;
                      
                      if (selection.baseOffset == selection.extentOffset) {
                        // No text selected, delete previous character
                        if (selection.baseOffset > 0) {
                          final newText = text.substring(0, selection.baseOffset - 1) +
                                       text.substring(selection.baseOffset);
                          _controller.value = TextEditingValue(
                            text: newText,
                            selection: TextSelection.collapsed(
                              offset: selection.baseOffset - 1,
                            ),
                          );
                        }
                      } else {
                        // Text selected, delete selection
                        final newText = text.substring(0, selection.start) +
                                     text.substring(selection.end);
                        _controller.value = TextEditingValue(
                          text: newText,
                          selection: TextSelection.collapsed(
                            offset: selection.start,
                          ),
                        );
                      }
                    }
                  },
                  child: TextField(
                    controller: _controller,
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
                    keyboardType: TextInputType.multiline,
                    enableInteractiveSelection: true,
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
                    onPressed: _saveAndPop,
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
