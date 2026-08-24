import 'package:flutter/material.dart';
import 'package:notepad/utils/hive_keys.dart';
import 'package:uuid/uuid.dart';

import '../models/reminder.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  static const Uuid _uuid = Uuid();
  final remindersBox = HiveKeys.remindersBox;

  List<Reminder> get all {
    return remindersBox.values.toList();
  }

    List<Reminder> get upcoming {
      final list = remindersBox.values
          .where(
            (r) => !r.isCompleted && !r.isPast,
          )
          .toList();

      list.sort(
        (a, b) => a.dateTime.compareTo(b.dateTime),
      );

      return list;
    }

  List<Reminder> get overdue {
    final list = remindersBox.values
        .where(
          (r) => !r.isCompleted && r.isPast,
        )
        .toList();

    list.sort(
      (a, b) => b.dateTime.compareTo(a.dateTime),
    );

    return list;
  }

  List<Reminder> get completed {
    final list = remindersBox.values
        .where(
          (r) => r.isCompleted,
        )
        .toList();

    list.sort(
      (a, b) => b.dateTime.compareTo(a.dateTime),
    );

    return list;
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

    await remindersBox.put(
      reminder.id,
      reminder,
    );
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
    final reminder = remindersBox.get(id);

    if (reminder == null) return;

    final updated = reminder.copyWith(
      title: title,
      description: description,
      dateTime: dateTime,
      isCompleted: false,
    );

    await remindersBox.put(
      id,
      updated,
    );

    await _syncNotification(updated);
    notifyListeners();
  }

  Future<void> toggleCompleted(String id) async {
    final reminder = remindersBox.get(id);

    if (reminder == null) return;

    final updated = reminder.copyWith(
      isCompleted: !reminder.isCompleted,
    );

    await remindersBox.put(
      id,
      updated,
    );

    if (updated.isCompleted) {
      await NotificationService.instance.cancelReminder(id);
    } else {
      await _syncNotification(updated);
    }

    notifyListeners();
  }

  Future<void> deleteReminder(String id) async {
    await remindersBox.delete(id);

    await NotificationService.instance.cancelReminder(id);
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

  Future<void> resyncAll() async {
    for (final reminder in remindersBox.values) {
      if (!reminder.isCompleted && !reminder.isPast) {
        await _syncNotification(reminder);
      }
    }
  }
}
