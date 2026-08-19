import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/reminder.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  static const String _prefsKey = 'reminders_data';
  static const Uuid _uuid = Uuid();

  List<Reminder> _reminders = [];

  List<Reminder> get all => List.unmodifiable(_reminders);

  /// Upcoming (not completed, not yet past), soonest first.
  List<Reminder> get upcoming {
    final list = _reminders
        .where((r) => !r.isCompleted && !r.isPast)
        .toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  /// Past-due but not marked completed, most recent first.
  List<Reminder> get overdue {
    final list =
        _reminders.where((r) => !r.isCompleted && r.isPast).toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<Reminder> get completed {
    final list = _reminders.where((r) => r.isCompleted).toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  ReminderProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _reminders = decoded
          .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  Future<Reminder> addReminder({
    required String title,
    String description = '',
    required DateTime dateTime,
  }) async {
    final reminder = Reminder(
      id: _uuid.v4(),
      title: title,
      description: description,
      dateTime: dateTime,
      createdAt: DateTime.now(),
    );
    _reminders.add(reminder);
    await _persist();
    await _syncNotification(reminder);
    notifyListeners();
    return reminder;
  }

  Future<void> updateReminder(
    String id, {
    String? title,
    String? description,
    DateTime? dateTime,
  }) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final updated = _reminders[index].copyWith(
      title: title,
      description: description,
      dateTime: dateTime,
      isCompleted: false, // editing time reactivates a completed reminder
    );
    _reminders[index] = updated;
    await _persist();
    await _syncNotification(updated);
    notifyListeners();
  }

  Future<void> toggleCompleted(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;
    final updated =
        _reminders[index].copyWith(isCompleted: !_reminders[index].isCompleted);
    _reminders[index] = updated;
    await _persist();
    if (updated.isCompleted) {
      await NotificationService.instance.cancelReminder(id);
    } else {
      await _syncNotification(updated);
    }
    notifyListeners();
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    await NotificationService.instance.cancelReminder(id);
    await _persist();
    notifyListeners();
  }

  Future<void> _syncNotification(Reminder reminder) async {
    if (reminder.isCompleted || reminder.dateTime.isBefore(DateTime.now())) {
      await NotificationService.instance.cancelReminder(reminder.id);
      return;
    }
    await NotificationService.instance.scheduleReminder(
      id: reminder.id,
      title: reminder.title.isEmpty ? 'Reminder' : reminder.title,
      body: reminder.description.isEmpty
          ? 'Tap to view your reminder'
          : reminder.description,
      scheduledDate: reminder.dateTime,
    );
  }

  /// Re-schedules all future, incomplete reminders. Call on app startup,
  /// since the OS can clear pending alarms (e.g. after a device reboot).
  Future<void> resyncAll() async {
    for (final reminder in _reminders) {
      if (!reminder.isCompleted && !reminder.isPast) {
        await _syncNotification(reminder);
      }
    }
  }
}
