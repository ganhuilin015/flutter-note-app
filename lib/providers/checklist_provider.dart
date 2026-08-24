import 'package:flutter/material.dart';
import 'package:notepad/utils/hive_keys.dart';
import 'package:uuid/uuid.dart';

import '../models/checklist.dart';
import '../models/checklist_item.dart';

class ChecklistProvider extends ChangeNotifier {
  static const Uuid _uuid = Uuid();

  List<Checklist> get checklists {
    final list = HiveKeys.checklistsBox.values.toList();

    list.sort(
      (a, b) => b.updatedAt.compareTo(a.updatedAt),
    );

    return list;
  }

  Future<Checklist> addChecklist(String name) async {
    final now = DateTime.now();

    final checklist = Checklist(
      id: _uuid.v4(),
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
      isBookmarked: false,
    );

    await HiveKeys.checklistsBox.put(
      checklist.id,
      checklist,
    );


    notifyListeners();
    return checklist;
  }

  Future<void> renameChecklist(
    String id,
    String name,
  ) async {
    final checklist = HiveKeys.checklistsBox.get(id);
    if (checklist == null) return;

    final trimmed = name.trim();


    final updated = checklist.copyWith(
      name: trimmed.isEmpty ? checklist.name : trimmed,
      updatedAt: DateTime.now(),
    );

    await HiveKeys.checklistsBox.put(
      id,
      updated,
    );

    notifyListeners();
  }

  Future<void> deleteChecklist(String id) async {
    await HiveKeys.checklistsBox.delete(id);

    final itemsToDelete = HiveKeys.itemsBox.values
        .where((item) => item.checklistId == id)
        .map((item) => item.id)
        .toList();

    await HiveKeys.itemsBox.deleteAll(itemsToDelete);

    notifyListeners();
  }

  Checklist? checklistById(String id) {
    return HiveKeys.checklistsBox.get(id);
  }

  List<ChecklistItem> blocks(String checklistId) {
    final list = HiveKeys.itemsBox.values
        .where(
          (item) => item.checklistId == checklistId,
        )
        .toList();

    list.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );

    return list;
  }

  Future<String> addTextBlock(
    String checklistId, {
    String text = '',
    DateTime? createdAt,
  }) async {
    final id = _uuid.v4();

    final item = ChecklistItem(
      id: id,
      checklistId: checklistId,
      name: text,
      quantity: '',
      isChecked: false,
      isCheckbox: false,
      createdAt: createdAt ?? DateTime.now(),
    );

    await HiveKeys.itemsBox.put(
      id,
      item,
    );

    await _touchChecklist(checklistId);

    notifyListeners();

    return id;
  }

  Future<String> addCheckbox(
    String checklistId, {
    String text = '',
    DateTime? createdAt,
  }) async {
    final id = _uuid.v4();

    final item = ChecklistItem(
      id: id,
      checklistId: checklistId,
      name: text,
      quantity: '',
      isChecked: false,
      isCheckbox: true,
      createdAt: createdAt ?? DateTime.now(),
    );

    await HiveKeys.itemsBox.put(
      id,
      item,
    );

    await _touchChecklist(checklistId);

    notifyListeners();

    return id;
  }

  Future<void> updateBlock(
    String id, {
    String? name,
  }) async {
    final item = HiveKeys.itemsBox.get(id);

    if (item == null) return;

    final updated = item.copyWith(
      name: name,
    );

    await HiveKeys.itemsBox.put(
      id,
      updated,
    );

    await _touchChecklist(
      item.checklistId,
    );

    notifyListeners();
  }

  Future<void> toggleChecked(String id) async {
    final item = HiveKeys.itemsBox.get(id);

    if (item == null) return;

    if (!item.isCheckbox) return;

    final updated = item.copyWith(
      isChecked: !item.isChecked,
    );

    await HiveKeys.itemsBox.put(
      id,
      updated,
    );

    await _touchChecklist(
      item.checklistId,
    );

    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    final item = HiveKeys.itemsBox.get(id);

    if (item == null) return;

    final checklistId = item.checklistId;

    await HiveKeys.itemsBox.delete(id);

    await _touchChecklist(checklistId);

    notifyListeners();
  }

  Future<void> clearChecked(
    String checklistId,
  ) async {
    final ids = HiveKeys.itemsBox.values
        .where(
          (item) =>
              item.checklistId == checklistId &&
              item.isCheckbox &&
              item.isChecked,
        )
        .map((item) => item.id)
        .toList();

    await HiveKeys.itemsBox.deleteAll(ids);

    await _touchChecklist(checklistId);

    notifyListeners();
  }

  Future<void> toggleBookmark(String id) async {
    final checklist = HiveKeys.checklistsBox.get(id);

    if (checklist == null) return;

    final updated = checklist.copyWith(
      isBookmarked: !checklist.isBookmarked,
      updatedAt: DateTime.now(),
    );

    await HiveKeys.checklistsBox.put(
      id,
      updated,
    );

    notifyListeners();
  }

  Future<void> _touchChecklist(String checklistId)  async {
    final checklist = HiveKeys.checklistsBox.get(checklistId);

    if (checklist == null) return;

    final updated = checklist.copyWith(
      updatedAt: DateTime.now(),
    );

    await HiveKeys.checklistsBox.put(
      checklistId,
      updated,
    );
  }

  int totalCount(String checklistId) {
    return HiveKeys.itemsBox.values
        .where(
          (item) =>
              item.checklistId == checklistId &&
              item.isCheckbox,
        )
        .length;
  }

  int checkedCount(String checklistId) {
    return HiveKeys.itemsBox.values
        .where(
          (item) =>
              item.checklistId == checklistId &&
              item.isCheckbox &&
              item.isChecked,
        )
        .length;
  }

  List<Checklist> get bookmarkedChecklists {
    return HiveKeys.checklistsBox.values
        .where(
          (checklist) => checklist.isBookmarked,
        )
        .toList()
      ..sort(
        (a, b) =>
            b.updatedAt.compareTo(a.updatedAt),
      );
  }
}