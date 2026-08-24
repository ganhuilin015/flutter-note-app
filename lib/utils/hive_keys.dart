import 'package:hive_ce/hive.dart';
import 'package:notepad/models/checklist.dart';
import 'package:notepad/models/checklist_item.dart';
import 'package:notepad/models/note.dart';
import 'package:notepad/models/reminder.dart';

class HiveKeys {
  HiveKeys._();

  static const _checklistsBoxName = 'checklists';
  static const _itemsBoxName = 'checklist_items';
  static const _notesBoxName = 'notes';
  static const _remindersBoxName = 'reminders';
  static const _themeBoxName = 'theme';

  static Box<Checklist> get checklistsBox =>
      Hive.box<Checklist>(_checklistsBoxName);
  static Box<ChecklistItem> get itemsBox =>
      Hive.box<ChecklistItem>(_itemsBoxName);
  static Box<Note> get notesBox => Hive.box<Note>(_notesBoxName);
  static Box<Reminder> get remindersBox =>
      Hive.box<Reminder>(_remindersBoxName);
  static Box get themeBox => Hive.box(_themeBoxName);
}
