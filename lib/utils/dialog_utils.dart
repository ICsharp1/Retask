import 'package:flutter/material.dart';
import '../widgets/dialogs/text_input_dialog.dart';
import '../widgets/dialogs/add_options_dialog.dart';
import '../widgets/dialogs/confirm_dialog.dart';

class DialogUtils {
  static Future<void> showTextInput({
    required BuildContext context,
    required String title,
    String initialText = '',
    required Function(String) onSave,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => TextInputDialog(
        title: title,
        initialText: initialText,
        onSave: onSave,
      ),
    );
  }

  static Future<void> showAddOptions({
    required BuildContext context,
    required Function() onAddText,
    required Function() onAddStep,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AddOptionsDialog(
        onAddText: onAddText,
        onAddStep: onAddStep,
      ),
    );
  }

  static Future<void> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Delete',
    required Function() onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
    );
  }
}
