import 'package:hive_ce/hive.dart';
import 'package:notepad/models/checklist.dart';
import 'package:notepad/models/checklist_item.dart';

class HiveKeys {
  HiveKeys._();

  static const checklistsBoxName = 'checklists';
  static const itemsBoxName = 'checklist_items';

  static Box<Checklist> get checklistsBox => Hive.box<Checklist>(checklistsBoxName);
  static Box<ChecklistItem> get itemsBox => Hive.box<ChecklistItem>(itemsBoxName);
}