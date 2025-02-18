import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'dart:io' show Platform, Process;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications;
  bool _initialized = false;

  NotificationService(this._notifications) {
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    if (_initialized) return;
    
    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize notification settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    
    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    // Initialize notifications
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );

    // Request permissions on supported platforms
    await _requestPermissions();
    
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }
    } else if (Platform.isIOS) {
      final iosImplementation = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    }
  }

  // Check if notifications are enabled on Linux
  Future<bool> checkLinuxNotificationsEnabled() async {
    if (!Platform.isLinux) return true;
    
    try {
      // Try to get the current notification settings using gsettings
      final result = await Process.run('gsettings', [
        'get',
        'org.gnome.desktop.notifications',
        'show-banners'
      ]);
      
      return result.stdout.toString().trim() == 'true';
    } catch (e) {
      print('Error checking notification settings: $e');
      return true; // Assume enabled if we can't check
    }
  }

  // Show dialog to guide users to notification settings
  Future<void> showNotificationSettingsDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Notifications'),
          content: const Text(
            'Notifications appear to be disabled. Please enable them in your system settings:\n\n'
            '1. Open System Settings\n'
            '2. Go to Notifications\n'
            '3. Enable notifications for this app'
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> scheduleNotification(Task task, {BuildContext? context}) async {
    if (!task.hasNotification || task.notificationTime == null) return false;

    // Check if notifications are enabled on Linux
    if (Platform.isLinux && context != null) {
      final enabled = await checkLinuxNotificationsEnabled();
      if (!enabled) {
        await showNotificationSettingsDialog(context);
        return false;
      }
    }

    try {
      // Create notification time based on task's due date and notification time
      final now = DateTime.now();
      final scheduledDate = DateTime(
        task.nextDue.year,
        task.nextDue.month,
        task.nextDue.day,
        task.notificationTime!.hour,
        task.notificationTime!.minute,
      );

      // Don't schedule if the time has passed
      if (scheduledDate.isBefore(now)) return false;

      // Cancel any existing notification for this task
      await _notifications.cancel(task.hashCode);

      // Schedule new notification
      await _notifications.zonedSchedule(
        task.hashCode,
        'Task Due: ${task.title}',
        'This task is due today',
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: const AndroidNotificationDetails(
            'task_channel',
            'Task Notifications',
            channelDescription: 'Notifications for due tasks',
            importance: Importance.high,
            priority: Priority.high,
            enableLights: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          linux: const LinuxNotificationDetails(
            urgency: LinuxNotificationUrgency.normal,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      return true;
    } catch (e) {
      print('Error scheduling notification: $e');
      return false;
    }
  }

  Future<void> cancelNotification(Task task) async {
    await _notifications.cancel(task.hashCode);
  }
}