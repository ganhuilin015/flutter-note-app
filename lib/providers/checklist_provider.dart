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

  /// All checklists, most recently updated first.
  List<Checklist> get checklists {
    final list = List<Checklist>.from(_checklists);
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  ChecklistProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final String? rawChecklists = prefs.getString(_checklistsKey);
    if (rawChecklists != null && rawChecklists.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(rawChecklists) as List<dynamic>;
      _checklists = decoded
          .map((e) => Checklist.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final String? rawItems = prefs.getString(_itemsKey);
    if (rawItems != null && rawItems.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(rawItems) as List<dynamic>;
      _items = decoded
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Seed a default "Groceries" checklist on very first launch so the
    // tab isn't empty before the user has created anything.
    if (_checklists.isEmpty && rawChecklists == null) {
      final now = DateTime.now();
      _checklists.add(Checklist(
        id: _uuid.v4(),
        name: 'Groceries',
        createdAt: now,
        updatedAt: now,
      ));
      await _persistChecklists();
    }

    notifyListeners();
  }

  Future<void> _persistChecklists() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(_checklists.map((c) => c.toJson()).toList());
    await prefs.setString(_checklistsKey, encoded);
  }

  Future<void> _persistItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_items.map((i) => i.toJson()).toList());
    await prefs.setString(_itemsKey, encoded);
  }

  // ---- Checklists ----

  Future<Checklist> addChecklist(String name) async {
    final now = DateTime.now();
    final checklist = Checklist(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? 'Untitled checklist' : name.trim(),
      createdAt: now,
      updatedAt: now,
    );
    _checklists.add(checklist);
    await _persistChecklists();
    notifyListeners();
    return checklist;
  }

  Future<void> renameChecklist(String id, String name) async {
    final index = _checklists.indexWhere((c) => c.id == id);
    if (index == -1) return;
    _checklists[index] = _checklists[index].copyWith(
      name: name.trim().isEmpty ? _checklists[index].name : name.trim(),
      updatedAt: DateTime.now(),
    );
    await _persistChecklists();
    notifyListeners();
  }

  Future<void> deleteChecklist(String id) async {
    _checklists.removeWhere((c) => c.id == id);
    _items.removeWhere((i) => i.checklistId == id);
    await _persistChecklists();
    await _persistItems();
    notifyListeners();
  }

  Checklist? checklistById(String id) {
    try {
      return _checklists.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---- Items (scoped to a checklist) ----

  List<ChecklistItem> pendingItems(String checklistId) {
    final list = _items
        .where((i) => i.checklistId == checklistId && !i.isChecked)
        .toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  List<ChecklistItem> checkedItems(String checklistId) {
    final list = _items
        .where((i) => i.checklistId == checklistId && i.isChecked)
        .toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  int totalCount(String checklistId) =>
      _items.where((i) => i.checklistId == checklistId).length;

  int checkedCount(String checklistId) => _items
      .where((i) => i.checklistId == checklistId && i.isChecked)
      .length;

  Future<void> addItem(String checklistId, String name,
      {String quantity = ''}) async {
    if (name.trim().isEmpty) return;
    _items.add(ChecklistItem(
      id: _uuid.v4(),
      checklistId: checklistId,
      name: name.trim(),
      quantity: quantity.trim(),
      createdAt: DateTime.now(),
    ));
    await _persistItems();
    _touchChecklist(checklistId);
    notifyListeners();
  }

  Future<void> toggleChecked(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _items[index] =
        _items[index].copyWith(isChecked: !_items[index].isChecked);
    await _persistItems();
    _touchChecklist(_items[index].checklistId);
    notifyListeners();
  }

  Future<void> updateItem(String id, {String? name, String? quantity}) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(name: name, quantity: quantity);
    await _persistItems();
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _persistItems();
    notifyListeners();
  }

  Future<void> clearChecked(String checklistId) async {
    _items.removeWhere((i) => i.checklistId == checklistId && i.isChecked);
    await _persistItems();
    notifyListeners();
  }

  /// Bumps a checklist's updatedAt so "most recently used" ordering works,
  /// without awaiting the persistence write on the caller.
  void _touchChecklist(String checklistId) {
    final index = _checklists.indexWhere((c) => c.id == checklistId);
    if (index == -1) return;
    _checklists[index] =
        _checklists[index].copyWith(updatedAt: DateTime.now());
    _persistChecklists();
  }
}
