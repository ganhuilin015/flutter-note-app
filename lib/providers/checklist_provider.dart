import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/checklist.dart';
import '../models/checklist_item.dart';

class ChecklistProvider extends ChangeNotifier {
  static const String _checklistsKey = 'checklists_data';
  static const String _itemsKey = 'checklist_items_data';

  static const Uuid _uuid = Uuid();

  List<Checklist> _checklists = [];
  List<ChecklistItem> _items = [];

  List<Checklist> get checklists {
    final list = List<Checklist>.from(_checklists);

    list.sort(
      (a, b) => b.updatedAt.compareTo(a.updatedAt),
    );

    return list;
  }

  ChecklistProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final String? rawChecklists =
        prefs.getString(_checklistsKey);

    if (rawChecklists != null && rawChecklists.isNotEmpty) {
      final List<dynamic> decoded =
          jsonDecode(rawChecklists) as List<dynamic>;

      _checklists = decoded
          .map(
            (e) => Checklist.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    final String? rawItems =
        prefs.getString(_itemsKey);

    if (rawItems != null && rawItems.isNotEmpty) {
      final List<dynamic> decoded =
          jsonDecode(rawItems) as List<dynamic>;

      _items = decoded
          .map(
            (e) => ChecklistItem.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    if (_checklists.isEmpty && rawChecklists == null) {
      final now = DateTime.now();

      _checklists.add(
        Checklist(
          id: _uuid.v4(),
          name: 'Groceries',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await _persistChecklists();
    }

    notifyListeners();
  }

  Future<void> _persistChecklists() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _checklists.map((c) => c.toJson()).toList(),
    );

    await prefs.setString(
      _checklistsKey,
      encoded,
    );
  }

  Future<void> _persistItems() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _items.map((i) => i.toJson()).toList(),
    );

    await prefs.setString(
      _itemsKey,
      encoded,
    );
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

    _checklists.add(checklist);

    await _persistChecklists();

    notifyListeners();

    return checklist;
  }

  Future<void> renameChecklist(
    String id,
    String name,
  ) async {
    final index =
        _checklists.indexWhere((c) => c.id == id);

    if (index == -1) return;

    final current = _checklists[index];

    final trimmed = name.trim();

    _checklists[index] = current.copyWith(
      name: trimmed.isEmpty ? current.name : trimmed,
      updatedAt: DateTime.now(),
    );

    await _persistChecklists();

    notifyListeners();
  }

  Future<void> deleteChecklist(String id) async {
    _checklists.removeWhere(
      (c) => c.id == id,
    );

    _items.removeWhere(
      (i) => i.checklistId == id,
    );

    await _persistChecklists();
    await _persistItems();

    notifyListeners();
  }

  Checklist? checklistById(String id) {
    try {
      return checklists.firstWhere(
        (c) => c.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  List<ChecklistItem> blocks(String checklistId) {
    final list = _items
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

    _items.add(
      ChecklistItem(
        id: id,
        checklistId: checklistId,
        name: text,
        quantity: '',
        isChecked: false,
        isCheckbox: false,
        createdAt: createdAt ?? DateTime.now(),
      ),
    );

    await _persistItems();

    _touchChecklist(checklistId);

    notifyListeners();

    return id;
  }

  Future<String> addCheckbox(
    String checklistId, {
    String text = '',
    DateTime? createdAt,
  }) async {
    final id = _uuid.v4();

    _items.add(
      ChecklistItem(
        id: id,
        checklistId: checklistId,
        name: text,
        quantity: '',
        isChecked: false,
        isCheckbox: true,
        createdAt: createdAt ?? DateTime.now(),
      ),
    );

    await _persistItems();

    _touchChecklist(checklistId);

    notifyListeners();

    return id;
  }

  Future<void> updateBlock(
    String id, {
    String? name,
  }) async {
    final index =
        _items.indexWhere((item) => item.id == id);

    if (index == -1) return;

    _items[index] = _items[index].copyWith(
      name: name,
    );

    await _persistItems();

    _touchChecklist(
      _items[index].checklistId,
    );

    notifyListeners();
  }

  Future<void> toggleChecked(String id) async {
    final index =
        _items.indexWhere((item) => item.id == id);

    if (index == -1) return;

    final item = _items[index];

    if (!item.isCheckbox) return;

    _items[index] = item.copyWith(
      isChecked: !item.isChecked,
    );

    await _persistItems();

    _touchChecklist(
      item.checklistId,
    );

    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    final index =
        _items.indexWhere((item) => item.id == id);

    if (index == -1) return;

    final checklistId =
        _items[index].checklistId;

    _items.removeAt(index);

    await _persistItems();

    _touchChecklist(checklistId);

    notifyListeners();
  }

  int totalCount(String checklistId) {
    return _items
        .where(
          (item) =>
              item.checklistId == checklistId &&
              item.isCheckbox,
        )
        .length;
  }

  int checkedCount(String checklistId) {
    return _items
        .where(
          (item) =>
              item.checklistId == checklistId &&
              item.isCheckbox &&
              item.isChecked,
        )
        .length;
  }

  Future<void> clearChecked(
    String checklistId,
  ) async {
    _items.removeWhere(
      (item) =>
          item.checklistId == checklistId &&
          item.isCheckbox &&
          item.isChecked,
    );

    await _persistItems();

    _touchChecklist(checklistId);

    notifyListeners();
  }

  Future<void> toggleBookmark(String id) async {
    final index =
        _checklists.indexWhere((c) => c.id == id);

    if (index == -1) return;

    final current = _checklists[index];

    _checklists[index] = current.copyWith(
      isBookmarked: !current.isBookmarked,
      updatedAt: DateTime.now(),
    );

    await _persistChecklists();

    notifyListeners();
  }

  List<Checklist> get bookmarkedChecklists {
    return _checklists
        .where(
          (checklist) => checklist.isBookmarked,
        )
        .toList()
      ..sort(
        (a, b) =>
            b.updatedAt.compareTo(a.updatedAt),
      );
  }


  void _touchChecklist(String checklistId) {
    final index =
        _checklists.indexWhere(
      (c) => c.id == checklistId,
    );

    if (index == -1) return;

    _checklists[index] =
        _checklists[index].copyWith(
      updatedAt: DateTime.now(),
    );

    _persistChecklists();
  }
}