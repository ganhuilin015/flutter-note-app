import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance =
      NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    try {
      final String localName = DateTime.now().timeZoneName;

      tz.setLocalLocation(
        tz.getLocation(localName),
      );
    } catch (_) {
      // Keep default timezone if lookup fails.
    }

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings =
        InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      settings: initSettings,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    _initialized = true;
  }

  NotificationDetails get _details =>
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          channelDescription:
              'Notifications for scheduled reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  int _idFromString(String id) {
    return id.hashCode & 0x7fffffff;
  }

  Future<void> scheduleReminderNotification({
    required String id,
    required String title,
    required String body,
    required DateTime reminderDate,
    required Duration offset,
  }) async {
    if (!_initialized) {
      await init();
    }

    final scheduledDate =
        reminderDate.subtract(offset);

    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    final notificationId =
        _idFromString(id);

    final tz.TZDateTime notificationDate =
        tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: notificationDate,
      notificationDetails: _details,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelReminderNotification(
    String id,
  ) async {
    if (!_initialized) {
      await init();
    }

    await _plugin.cancel(
      id: _idFromString(id),
    );
  }

  Future<void> cancelReminderNotifications(
    String reminderId,
  ) async {
    if (!_initialized) {
      await init();
    }

    for (final offset in [
      604800,
      432000,
      259200,
      86400,
      3600,
    ]) {
      final notificationId =
          '${reminderId}_$offset';

      await _plugin.cancel(
        id: _idFromString(notificationId),
      );
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) {
      await init();
    }

    await _plugin.cancelAll();
  }

  Future<void> requestExactAlarmPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestExactAlarmsPermission();
  }
}