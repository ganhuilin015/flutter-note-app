import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/checklist_provider.dart';

class ChecklistDialogs {
  static Future<void> promptRename(
    BuildContext context,
    String id,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename checklist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onSubmitted: (value) {
            Navigator.pop(ctx, value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (name == null || name.trim().isEmpty || !context.mounted) {
      return;
    }

    await context.read<ChecklistProvider>().renameChecklist(
      id,
      name.trim(),
    );
  }
}