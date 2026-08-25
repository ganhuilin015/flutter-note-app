import 'package:hive_ce/hive.dart';
import 'package:notepad/models/checklist.dart';
import 'package:notepad/models/checklist_item.dart';
import 'package:notepad/models/note.dart';
import 'package:notepad/models/reminder.dart';

class HiveKeys {
  HiveKeys._();

  static const checklistsBoxName = 'checklists';
  static const itemsBoxName = 'checklist_items';
  static const notesBoxName = 'notes';
  static const remindersBoxName = 'reminders';
  static const themeBoxName = 'theme';
  static const reminderSettingsBoxName = 'reminder_settings';

  static Box<Checklist> get checklistsBox =>
      Hive.box<Checklist>(checklistsBoxName);
  static Box<ChecklistItem> get itemsBox =>
      Hive.box<ChecklistItem>(itemsBoxName);
  static Box<Note> get notesBox => Hive.box<Note>(notesBoxName);
  static Box<Reminder> get remindersBox =>
      Hive.box<Reminder>(remindersBoxName);
  static Box get themeBox => Hive.box(themeBoxName);
  static Box get reminderSettingsBox => Hive.box(reminderSettingsBoxName);
}
