import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart'; 
import 'package:package_info_plus/package_info_plus.dart';

class PermissionService {
  static Future<bool> isNotificationGranted() async {
    return await Permission.notification.isGranted;
  }


  static Future<void> requestNotification() async {
    await Permission.notification.request();
  }

  static Future<bool> isExactAlarmGranted() async {
    if (!Platform.isAndroid) return false; 

    return await Permission.scheduleExactAlarm.isGranted;
  }

  static Future<void> requestExactAlarm() async {
    if (!Platform.isAndroid) return;

    final packageInfo = await PackageInfo.fromPlatform();

    final intent = AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      data: 'package:${packageInfo.packageName}',
    );

    await intent.launch();
  }
  
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}