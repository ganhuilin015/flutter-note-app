import 'package:flutter/material.dart';
import 'package:notepad/utils/hive_keys.dart';
import 'package:uuid/uuid.dart';

import '../models/reminder.dart';
import '../services/notification_service.dart';
import 'reminder_settings_provider.dart';

class ReminderProvider extends ChangeNotifier {
  static const Uuid _uuid = Uuid();

  final remindersBox = HiveKeys.remindersBox;

  final ReminderSettingsProvider settingsProvider;

  ReminderProvider(this.settingsProvider);

  List<Reminder> get all {
    return remindersBox.values.toList();
  }

  List<Reminder> get upcoming {
    final list = remindersBox.values
        .where(
          (r) =>
              !r.isCompleted &&
              !r.isPast,
        )
        .toList();

    list.sort(
      (a, b) =>
          a.dateTime.compareTo(b.dateTime),
    );

    return list;
  }

  List<Reminder> get overdue {
    final list = remindersBox.values
        .where(
          (r) =>
              !r.isCompleted &&
              r.isPast,
        )
        .toList();

    list.sort(
      (a, b) =>
          b.dateTime.compareTo(a.dateTime),
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
      (a, b) =>
          b.dateTime.compareTo(a.dateTime),
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

    // Cancel old notifications first.
    await NotificationService.instance
        .cancelReminderNotifications(id);

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

  Future<void> toggleCompleted(
    String id,
  ) async {
    final reminder = remindersBox.get(id);

    if (reminder == null) return;

    final updated = reminder.copyWith(
      isCompleted: !reminder.isCompleted,
    );

    await remindersBox.put(
      id,
      updated,
    );

    await _syncNotification(updated);

    notifyListeners();
  }

  Future<void> deleteReminder(
    String id,
  ) async {
    await remindersBox.delete(id);

    await NotificationService.instance
        .cancelReminderNotifications(id);

    notifyListeners();
  }

  Future<void> _syncNotification(
    Reminder reminder,
  ) async {
    await NotificationService.instance
        .cancelReminderNotifications(
      reminder.id,
    );

    if (reminder.isCompleted) {
      return;
    }

    if (reminder.dateTime.isBefore(
      DateTime.now(),
    )) {
      return;
    }

    await _scheduleReminderNotifications(
      reminder,
    );
  }

  Future<void> _scheduleReminderNotifications(
    Reminder reminder,
  ) async {
    final offsets =
        settingsProvider.notificationOffsets;

    if (offsets.isEmpty) {
      return;
    }

    for (final offsetSeconds in offsets) {
      final offset = Duration(
        seconds: offsetSeconds,
      );

      final notificationTime =
          reminder.dateTime.subtract(offset);

      if (notificationTime.isBefore(
        DateTime.now(),
      )) {
        continue;
      }

      await NotificationService.instance
          .scheduleReminderNotification(
        id: '${reminder.id}_$offsetSeconds',
        title: reminder.title.isEmpty
            ? 'Reminder'
            : reminder.title,
        body: reminder.description.isEmpty
            ? 'Upcoming reminder'
            : reminder.description,
        reminderDate: reminder.dateTime,
        offset: offset,
      );
    }
  }

  Future<void> rescheduleAllReminders() async {
    for (final reminder in all) {
      if (reminder.isCompleted) {
        await NotificationService.instance
            .cancelReminderNotifications(
          reminder.id,
        );
        continue;
      }

      if (reminder.dateTime.isBefore(
        DateTime.now(),
      )) {
        await NotificationService.instance
            .cancelReminderNotifications(
          reminder.id,
        );
        continue;
      }

      await _syncNotification(reminder);
    }
  }
}