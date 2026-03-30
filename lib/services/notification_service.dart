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

  /// Available notification sounds with display names
  static const Map<String, String> availableSounds = {
    'alexzavesa_water_drop_notification_1_463596_mp3_mpeg': 'Water Drop 1',
    'alexzavesa_water_drop_notification_3_463594_mp3_mpeg': 'Water Drop 2',
    'floraphonic_water_droplet_4_165639_mp3_mpeg': 'Water Droplet',
    'freesound_community_water_drop_85731_mp3_mpeg': 'Water Drop Classic',
    'universfield_water_splash_199583__1__mp3_mpeg': 'Water Splash',
  };

  /// Time-based notification messages for variety
  static String getMessageForTime(int hour) {
    if (hour < 8) {
      return _morningMessages[hour % _morningMessages.length];
    } else if (hour < 12) {
      return _midMorningMessages[hour % _midMorningMessages.length];
    } else if (hour < 14) {
      return _lunchMessages[hour % _lunchMessages.length];
    } else if (hour < 17) {
      return _afternoonMessages[hour % _afternoonMessages.length];
    } else if (hour < 20) {
      return _eveningMessages[hour % _eveningMessages.length];
    } else {
      return _nightMessages[hour % _nightMessages.length];
    }
  }

  static const _morningMessages = [
    'Rise and hydrate! ☀️',
    'Start your day with water! 🌅',
    'Morning hydration boost! 💧',
  ];
  static const _midMorningMessages = [
    'Mid-morning water break! 💦',
    'Keep the momentum — drink up! 🚀',
    'Stay sharp, stay hydrated! 🧠',
    'Your body is craving water! 💧',
  ];
  static const _lunchMessages = [
    'Pre-lunch hydration! 🥗',
    'Don\'t forget water with your meal! 🍽️',
    'Lunch break = water break! 💧',
  ];
  static const _afternoonMessages = [
    'Afternoon slump? Water helps! ⚡',
    'Beat the 3pm crash — hydrate! 💪',
    'Your cells need water right now! 🫧',
    'Quick sip to power through! 🥤',
  ];
  static const _eveningMessages = [
    'Evening hydration check! 🌆',
    'Almost done for today — drink up! 🎯',
    'Finish strong with a glass of water! 💧',
  ];
  static const _nightMessages = [
    'Last call for hydration! 🌙',
    'Wind down with some water! ✨',
    'A nightcap of H₂O! 💧',
  ];

  /// Notification body messages (also varied by time)
  static String getBodyForTime(int hour) {
    if (hour < 12) {
      return 'A glass of water now keeps you energized all morning.';
    } else if (hour < 17) {
      return 'Stay focused and productive — your body needs water.';
    } else {
      return 'Finish today\'s hydration goal strong!';
    }
  }

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_stat_water_bottle');
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
    String soundName = 'floraphonic_water_droplet_4_165639_mp3_mpeg',
    List<TimeOfDay>? customTimes,
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
      'aqua_reminders_$soundName',
      'Hydration Reminders',
      channelDescription: 'Reminders to drink water throughout the day',
      importance: Importance.max,
      priority: Priority.high,
      playSound: soundEnabled,
      enableVibration: vibrationEnabled,
      groupKey: 'com.aqua.DRINK_REMINDERS',
      setAsGroupSummary: false,
      sound: soundEnabled
          ? RawResourceAndroidNotificationSound(soundName)
          : null,
    );
    final details = NotificationDetails(android: androidDetails);

    if (customTimes != null && customTimes.isNotEmpty) {
      // Schedule at specific custom times
      int id = 0;
      for (final time in customTimes) {
        DateTime scheduleTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        final title = getMessageForTime(time.hour);
        final body = getBodyForTime(time.hour);
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(scheduleTime, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        id++;
      }
    } else {
      // Schedule at regular intervals
      DateTime current = wake.add(Duration(minutes: intervalMin));
      int id = 0;

      while (current.isBefore(sleep) && id < 30) {
        final title = getMessageForTime(current.hour);
        final body = getBodyForTime(current.hour);
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(current, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        current = current.add(Duration(minutes: intervalMin));
        id++;
      }
    }
  }

  /// Fire a test notification immediately to preview a sound.
  /// Uses a unique channel ID with timestamp to bypass Android's channel caching,
  /// ensuring each preview actually plays the selected sound.
  Future<void> playTestNotification({
    required String soundName,
    required bool vibrationEnabled,
  }) async {
    final displayName = availableSounds[soundName] ?? 'Unknown';
    // Android caches notification channel settings. Using a unique channel ID
    // for each preview forces a fresh channel with the correct sound.
    final uniqueChannelId = 'aqua_preview_${soundName}_${DateTime.now().millisecondsSinceEpoch}';
    
    final androidDetails = AndroidNotificationDetails(
      uniqueChannelId,
      'Sound Preview: $displayName',
      channelDescription: 'Preview notification sound',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: vibrationEnabled,
      sound: RawResourceAndroidNotificationSound(soundName),
    );
    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: 9999,
      title: '🔊 $displayName',
      body: 'This is how your reminder will sound',
      notificationDetails: details,
    );
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
