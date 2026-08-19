import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Wraps flutter_local_notifications to schedule, cancel, and show
/// local notifications, keyed by an arbitrary string id (e.g. a reminder's id).
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // Falls back to UTC if the local timezone can't be resolved on-device;
    // scheduled times are still computed correctly as long as the device
    // timezone doesn't change between scheduling and firing.
    try {
      final String localName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      // Keep default UTC location if lookup fails.
    }

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings: initSettings);

    // Android 13+ requires runtime notification permission.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          channelDescription: 'Notifications for scheduled reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  /// Deterministic notification id derived from a string id, so scheduling
  /// under the same id twice reuses/replaces the same notification slot.
  int _idFromString(String id) => id.hashCode & 0x7fffffff;

  /// Schedules a one-off notification to fire at [scheduledDate].
  /// If the date is already in the past, nothing is scheduled.
  Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) {
      await init();
    }

    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    final int notificationId = _idFromString(id);

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

  Future<void> cancelReminder(String id) async {
    if (!_initialized) {
      await init();
    }

    await _plugin.cancel(
      id: _idFromString(id),
    );
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }
}
