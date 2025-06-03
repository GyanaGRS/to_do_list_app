import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notif;
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';
import '../models/task.dart';

class NotificationHelper {
  static Future<void> scheduleNotification(Task task) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(task.dueDate, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      'Task Reminder',
      '${task.title} is due soon!',
      scheduledDate.subtract(const Duration(minutes: 10)), // Notify 10 mins before
      const notif.NotificationDetails(
        android: notif.AndroidNotificationDetails(
          'todo_channel',
          'Task Reminders',
          importance: notif.Importance.max,
          priority: notif.Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      notif.UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: notif.DateTimeComponents.dateAndTime,
    );
  }

  static Future<void> cancelNotification(Task task) async {
    await flutterLocalNotificationsPlugin.cancel(task.id.hashCode);
  }
}
