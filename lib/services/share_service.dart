import 'package:notepad/models/checklist.dart';
import 'package:notepad/models/checklist_item.dart';
import 'package:share_plus/share_plus.dart';

import '../models/note.dart';

class ShareService {
  ShareService._();

  static Future<void> shareNote(Note note) async {
    final content = _formatNote(note);

    await SharePlus.instance.share(
      ShareParams(
        text: content,
        subject: note.title,
      ),
    );
  }

  static Future<void> shareChecklist(
    Checklist checklist,
    List<ChecklistItem> items,
  ) async {
    final content = _formatChecklist(
      checklist,
      items,
    );

    await SharePlus.instance.share(
      ShareParams(
        text: content,
        subject: checklist.name,
      ),
    );
  }

  static String _formatNote(Note note) {
    final title = note.title.trim();
    final content = note.content.trim();

    if (content.isEmpty) {
      return title;
    }

    return '$title\n\n$content';
  }

  static String _formatChecklist(
    Checklist checklist,
    List<ChecklistItem> items,
  ) {
    final title = checklist.name.trim();

    final lines = items.map((item) {
      final checkbox = item.isChecked ? '☑' : '☐';

      if (item.quantity.trim().isEmpty) {
        return '$checkbox ${item.name}';
      }

      return '$checkbox ${item.name} (${item.quantity})';
    }).join('\n');

    if (lines.isEmpty) {
      return title;
    }

    return '$title\n\n$lines';
  }
}