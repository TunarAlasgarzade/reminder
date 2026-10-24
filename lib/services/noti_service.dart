import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    final TimezoneInfo currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

    const initSettingsAndroid = AndroidInitializationSettings("@mipmap/ic_launcher");
    const initSettings = InitializationSettings(android: initSettingsAndroid);
    final androidImplementation =
    notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await notificationsPlugin.initialize(settings: initSettings);
    await androidImplementation?.requestNotificationsPermission();
  }
  
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        "reminder_channel_id", 
        "Reminder Notifications",
        channelDescription: "Reminder Notification Channel",
        importance: Importance.max,
        priority: Priority.high,
      )
    );
  }

  Future<void> scheduleNotification({
    required int id, 
    required String title, 
    required String body,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) async {
    var scheduledDate = tz.TZDateTime(
      tz.local, year, month,
      day, hour, minute,
    );

    await notificationsPlugin.zonedSchedule(
      id: id, 
      title: title,
      body: body,
      scheduledDate: scheduledDate, 
      notificationDetails: notificationDetails(), 
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
    );
  }

  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id: id);
  }
}