import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/grocery_item.dart';

class GroceryProvider extends ChangeNotifier {
  static const String _prefsKey = 'grocery_data';
  static const Uuid _uuid = Uuid();

  List<GroceryItem> _items = [];

  List<GroceryItem> get items => List.unmodifiable(_items);

  List<GroceryItem> get pendingItems =>
      _items.where((i) => !i.isChecked).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  List<GroceryItem> get checkedItems =>
      _items.where((i) => i.isChecked).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  int get totalCount => _items.length;
  int get checkedCount => _items.where((i) => i.isChecked).length;

  GroceryProvider() {
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _items = decoded
          .map((e) => GroceryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(_items.map((i) => i.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  Future<void> addItem(String name, {String quantity = ''}) async {
    if (name.trim().isEmpty) return;
    _items.add(GroceryItem(
      id: _uuid.v4(),
      name: name.trim(),
      quantity: quantity.trim(),
      createdAt: DateTime.now(),
    ));
    await _persist();
    notifyListeners();
  }

  Future<void> toggleChecked(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _items[index] =
        _items[index].copyWith(isChecked: !_items[index].isChecked);
    await _persist();
    notifyListeners();
  }

  Future<void> updateItem(String id, {String? name, String? quantity}) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(name: name, quantity: quantity);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> clearChecked() async {
    _items.removeWhere((i) => i.isChecked);
    await _persist();
    notifyListeners();
  }
}
