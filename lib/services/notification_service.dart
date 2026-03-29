import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings: initSettings,
    );
    _isInitialized = true;
  }

  Future<void> scheduleReminders({
    required TimeOfDay wakeTime,
    required TimeOfDay sleepTime,
    required int intervalMin,
    required bool enabled,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) async {
    await cancelAll();
    if (!enabled) return;

    final now = DateTime.now();
    DateTime wake = DateTime(
        now.year, now.month, now.day, wakeTime.hour, wakeTime.minute);
    DateTime sleep = DateTime(
        now.year, now.month, now.day, sleepTime.hour, sleepTime.minute);

    if (sleep.isBefore(wake)) {
      sleep = sleep.add(const Duration(days: 1));
    }

    final androidDetails = AndroidNotificationDetails(
      'aqua_reminders',
      'Hydration Reminders',
      channelDescription: 'Reminders to drink water throughout the day',
      importance: Importance.max,
      priority: Priority.high,
      playSound: soundEnabled,
      enableVibration: vibrationEnabled,
      groupKey: 'com.aqua.DRINK_REMINDERS',
      setAsGroupSummary: false,
      sound: soundEnabled
          ? const RawResourceAndroidNotificationSound(
              'floraphonic_water_droplet_4_165639_mp3_mpeg')
          : null,
    );
    final details = NotificationDetails(android: androidDetails);

    // Summary notification for grouping
    const summaryDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'aqua_reminders',
        'Hydration Reminders',
        channelDescription: 'Reminders to drink water throughout the day',
        importance: Importance.max,
        priority: Priority.high,
        groupKey: 'com.aqua.DRINK_REMINDERS',
        setAsGroupSummary: true,
        groupAlertBehavior: GroupAlertBehavior.all,
      ),
    );
    
    await _notificationsPlugin.show(
      id: -1,
      title: 'Hydration Status',
      body: 'You have multiple hydrate reminders.',
      notificationDetails: summaryDetails,
    );

    DateTime current = wake.add(Duration(minutes: intervalMin));
    int id = 0;

    while (current.isBefore(sleep) && id < 30) {
      // Schedule repeating daily logic
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Time to hydrate! 💧',
        body: 'Have a quick glass of water to stay on track.',
        scheduledDate: tz.TZDateTime.from(current, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      current = current.add(Duration(minutes: intervalMin));
      id++;
    }
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
