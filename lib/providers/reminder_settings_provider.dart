import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderSettingsProvider extends ChangeNotifier {
  static const String _key = 'reminder_notification_offsets';

  static const Map<int, String> availableOffsets = {
    604800: '1 week before',
    432000: '5 days before',
    259200: '3 days before',
    86400: '1 day before',
    3600: '1 hour before',
  };

  List<int> _notificationOffsets = [];

  List<int> get notificationOffsets =>
      List.unmodifiable(_notificationOffsets);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList(_key);

    if (saved == null) {
      _notificationOffsets = [86400];
    } else {
      _notificationOffsets = saved
          .map(int.parse)
          .toList();
    }

    notifyListeners();
  }

  bool isSelected(int offset) {
    return _notificationOffsets.contains(offset);
  }

  Future<void> toggleOffset(int offset) async {
    if (_notificationOffsets.contains(offset)) {
      _notificationOffsets.remove(offset);
    } else {
      _notificationOffsets.add(offset);
    }

    _notificationOffsets.sort(
      (a, b) => b.compareTo(a),
    );

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      _key,
      _notificationOffsets
          .map((value) => value.toString())
          .toList(),
    );

    notifyListeners();
  }
}