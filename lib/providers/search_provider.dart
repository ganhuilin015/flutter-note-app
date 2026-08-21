import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String _query = '';

  String get query => _query;

  bool get isSearching => _query.trim().isNotEmpty;

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void clear() {
    _query = '';
    notifyListeners();
  }
}