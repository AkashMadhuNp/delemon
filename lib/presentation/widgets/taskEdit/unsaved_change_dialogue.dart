import 'package:flutter/material.dart';

class UnsavedChangesDialog extends StatelessWidget {
  final String title;
  final String content;
  final String saveText;
  final String discardText;
  final String cancelText;

  const UnsavedChangesDialog({
    super.key,
    required this.title,
    required this.content,
    this.saveText = 'Save Changes',
    this.discardText = 'Discard',
    this.cancelText = 'Cancel',
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String saveText = 'Save Changes',
    String discardText = 'Discard',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UnsavedChangesDialog(
        title: title,
        content: content,
        saveText: saveText,
        discardText: discardText,
        cancelText: cancelText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(discardText),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, null), // null means save
          child: Text(saveText),
        ),
      ],
    );
  }
}
