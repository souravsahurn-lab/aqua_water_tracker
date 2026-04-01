import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/user_data.dart';
import '../models/drink_log.dart';
import '../utils/time_utils.dart';

// ── Isolate-safe state ──────────────────────────────────────────
// These are reset every isolate spawn — that is intentional.
// We no longer rely on them surviving across taps.
bool _isProcessing = false;
bool _pendingSync = false;
DateTime? _processingStarted;
const _lockTimeout = Duration(seconds: 5);

bool get _lockExpired =>
    _processingStarted != null &&
    DateTime.now().difference(_processingStarted!) > _lockTimeout;

UserData _loadUserData(SharedPreferences prefs) {
  final str = prefs.getString('userData');
  if (str == null) return UserData();
  try {
    return UserData.fromJson(jsonDecode(str));
  } catch (_) {
    return UserData();
  }
}

List<DrinkLog> _loadLogs(SharedPreferences prefs) {
  final str = prefs.getString('logs');
  if (str == null) return [];
  try {
    final List<dynamic> decoded = jsonDecode(str);
    return decoded.map((l) => DrinkLog.fromJson(l)).toList();
  } catch (_) {
    return [];
  }
}

// ── Background callback ─────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? uri) async {
  if (uri == null) return;

  // Step 1: write Flutter-side data (logs, userData)
  await _handleUri(uri);

  // Step 2: Kotlin already updated widget UI instantly — Dart handles charts/logs only
  if (_isProcessing && _lockExpired) {
    _isProcessing = false;
    _pendingSync = false;
    _processingStarted = null;
  }

  if (_isProcessing) {
    _pendingSync = true;
    return;
  }

  _isProcessing = true;
  _processingStarted = DateTime.now();
  try {
    // Coalesce rapid taps — wait briefly before heavy sync
    await Future.delayed(const Duration(milliseconds: 500));
    await WidgetService._syncChartsAndReminders();
    while (_pendingSync) {
      _pendingSync = false;
      _processingStarted = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 500));
      await WidgetService._syncChartsAndReminders();
    }
  } catch (_) {
  } finally {
    _isProcessing = false;
    _processingStarted = null;
  }
}

Future<void> _handleUri(Uri uri) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();

  if (uri.host == 'add') {
    final amount = int.tryParse(uri.pathSegments.firstOrNull ?? '0') ?? 0;
    if (amount <= 0) return;

    final userData = _loadUserData(prefs);
    final logs = _loadLogs(prefs);

    userData.drunk += amount;

    final now = DateTime.now();
    logs.insert(0, DrinkLog(
      date: now.toIso8601String().split('T')[0],
      time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      icon: '💧',
      label: 'Water',
      ml: amount,
    ));

    await prefs.setString('userData', jsonEncode(userData.toJson()));
    await prefs.setString('logs', jsonEncode(logs.map((e) => e.toJson()).toList()));
  }

  if (uri.host == 'undo') {
    final userData = _loadUserData(prefs);
    final logs = _loadLogs(prefs);

    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    if (logs.isNotEmpty && logs.first.date == todayStr) {
      final removed = logs.removeAt(0);
      userData.drunk -= removed.ml;
      if (userData.drunk < 0) userData.drunk = 0;

      await prefs.setString('userData', jsonEncode(userData.toJson()));
      await prefs.setString('logs', jsonEncode(logs.map((e) => e.toJson()).toList()));
    }
  }

  // sync — fired by WorkManager when a new widget is added
  // No data write needed — just let interactiveCallback run the full sync
  if (uri.host == 'sync') {
    // Nothing to write — fall through to chart sync in interactiveCallback
  }
}

class WidgetService {
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('');
    await HomeWidget.registerInteractivityCallback(interactiveCallback);
  }

  // ── Critical sync — fast, always called on every tap ──────────
  // Only writes intake/goal/streak/stack — completes in <100ms
  static Future<void> syncCriticalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      final userData = _loadUserData(prefs);
      final logs = _loadLogs(prefs);

      int displayStreak = userData.streak;
      if (userData.drunk >= userData.goal) displayStreak++;

      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final todayLogs = logs.where((l) => l.date == todayStr).toList();
      final lastAddedMl = todayLogs.isNotEmpty ? todayLogs.first.ml : 0;
      final stackStr = todayLogs.map((e) => '${e.ml}').join(',');
      final isPro = prefs.getBool('isPremium') ?? false;

      // Write all critical keys in parallel
      await Future.wait([
        HomeWidget.saveWidgetData<int>('intake', userData.drunk),
        HomeWidget.saveWidgetData<int>('goal', userData.goal),
        HomeWidget.saveWidgetData<int>('streak', displayStreak),
        HomeWidget.saveWidgetData<String>('volume_unit', userData.volumeUnit),
        HomeWidget.saveWidgetData<int>('last_added_ml', lastAddedMl),
        HomeWidget.saveWidgetData<String>('widget_add_stack', stackStr),
        HomeWidget.saveWidgetData<bool>('is_premium', isPro),
      ]);

      // Single trigger call — Glance fans out to all instances
      await _triggerAllWidgets();
    } catch (_) {}
  }

  // ── Charts + reminders sync — heavier, coalesced ──────────────
  static Future<void> _syncChartsAndReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      final userData = _loadUserData(prefs);
      final logs = _loadLogs(prefs);

      // Always re-push intake/goal in case Kotlin wrote a newer value
      int displayStreak = userData.streak;
      if (userData.drunk >= userData.goal) displayStreak++;

      await Future.wait([
        HomeWidget.saveWidgetData<int>('intake', userData.drunk),
        HomeWidget.saveWidgetData<int>('goal', userData.goal),
        HomeWidget.saveWidgetData<int>('streak', displayStreak),
      ]);

      await _writeHourlyData(prefs, userData, logs);
      await _writeWeeklyData(prefs, userData, logs);
      await _writeNextReminder(prefs, userData);

      // Final trigger — syncs chart data into widget
      await _triggerAllWidgets();
    } catch (_) {}
  }

  // ── Full sync — called from app foreground ─────────────────────
  static Future<void> syncFullWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      final userData = _loadUserData(prefs);
      final logs = _loadLogs(prefs);

      await updateWidgetData(userData, logs: logs);
    } catch (_) {}
  }

  // ── Trigger all widgets — ONE call per widget type ─────────────
  static Future<void> _triggerAllWidgets() async {
    // Sequential not parallel — parallel hammers Glance and causes drops
    await HomeWidget.updateWidget(
        name: 'WaterWidgetReceiver', androidName: 'WaterWidgetReceiver');
    await HomeWidget.updateWidget(
        name: 'HourlyWidgetReceiver', androidName: 'HourlyWidgetReceiver');
    await HomeWidget.updateWidget(
        name: 'WeeklyWidgetReceiver', androidName: 'WeeklyWidgetReceiver');
    await HomeWidget.updateWidget(
        name: 'BottleWidgetReceiver', androidName: 'BottleWidgetReceiver');
    await HomeWidget.updateWidget(
        name: 'GridWidgetReceiver', androidName: 'GridWidgetReceiver');
  }

  // ── Hourly data writer ─────────────────────────────────────────
  static Future<void> _writeHourlyData(
      SharedPreferences prefs, UserData userData, List<DrinkLog> logs) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final todayLogs = logs.where((l) => l.date == today).toList();

      int wakeH = 7, sleepH = 22;
      try {
        wakeH = int.parse(userData.wakeTime.split(':')[0]);
        sleepH = int.parse(userData.sleepTime.split(':')[0]);
      } catch (_) {}
      if (sleepH <= wakeH) sleepH += 24;

      List<int> slots = [];
      for (int h = wakeH; h < sleepH; h += 2) {
        slots.add(h % 24);
      }
      if (slots.isEmpty) slots = [7, 9, 11, 13, 15, 17, 19, 21];

      final List<int> values = List.filled(slots.length, 0);
      final List<String> labels = [];

      for (int i = 0; i < slots.length; i++) {
        final h = slots[i];
        final endH = (h + 2) % 24;
        
        final is24h = userData.is24HourFormat ?? false;
        if (is24h) {
          labels.add('${h.toString().padLeft(2, '0')}-${endH.toString().padLeft(2, '0')}h');
        } else {
          final sStr = TimeUtils.formatTimeOfDay(TimeOfDay(hour: h, minute: 0), false).replaceAll(' ', '').toLowerCase();
          final eStr = TimeUtils.formatTimeOfDay(TimeOfDay(hour: endH, minute: 0), false).replaceAll(' ', '').toLowerCase();
          labels.add('$sStr-$eStr');
        }
        for (var l in todayLogs) {
          try {
            final logH = int.parse(l.time.split(':')[0]);
            if (logH >= h && logH < h + 2) values[i] += l.ml;
          } catch (_) {}
        }
      }

      await Future.wait([
        HomeWidget.saveWidgetData<String>('hourly_vals', values.join(',')),
        HomeWidget.saveWidgetData<String>('hourly_labels', labels.join(',')),
      ]);
    } catch (_) {}
  }

  // ── Weekly data writer ─────────────────────────────────────────
  static Future<void> _writeWeeklyData(
      SharedPreferences prefs, UserData userData, List<DrinkLog> logs) async {
    try {
      final List<int> weeklyVals = [];
      final List<String> weeklyLabelsTop = [];
      final List<int> weeklyGoals = [];
      const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final now = DateTime.now();

      for (int i = 6; i >= 0; i--) {
        final targetDate = now.subtract(Duration(days: i));
        final dateStr = targetDate.toIso8601String().split('T')[0];
        final dayLogs = logs.where((l) => l.date == dateStr).toList();
        int dailyTotal = 0;
        for (var l in dayLogs) dailyTotal += l.ml;
        weeklyVals.add(dailyTotal);
        weeklyLabelsTop.add(weekDays[targetDate.weekday - 1]);
        weeklyGoals.add(userData.goalForDate(dateStr));
      }

      await Future.wait([
        HomeWidget.saveWidgetData<String>('weekly_vals', weeklyVals.join(',')),
        HomeWidget.saveWidgetData<String>(
            'weekly_labels_top', weeklyLabelsTop.join(',')),
        HomeWidget.saveWidgetData<String>(
            'weekly_goals', weeklyGoals.join(',')),
      ]);
    } catch (_) {}
  }

  // ── Next reminder writer ───────────────────────────────────────
  static Future<void> _writeNextReminder(
      SharedPreferences prefs, UserData userData) async {
    try {
      String nextReminder = '--:--';
      List<String> allTimes = List.from(userData.customReminderTimes);

      if (allTimes.isEmpty && userData.reminders) {
        int wakeH = 7, sleepH = 22;
        try {
          wakeH = int.parse(userData.wakeTime.split(':')[0]);
          sleepH = int.parse(userData.sleepTime.split(':')[0]);
        } catch (_) {}
        if (sleepH <= wakeH) sleepH += 24;

        final interval = userData.reminderIntervalMin;
        DateTime temp = DateTime(2024, 1, 1, wakeH, 0);
        DateTime limit = DateTime(2024, 1, 1, sleepH, 0);
        while (temp.isBefore(limit)) {
          allTimes.add(
              '${temp.hour.toString().padLeft(2, '0')}:${temp.minute.toString().padLeft(2, '0')}');
          temp = temp.add(Duration(minutes: interval));
        }
      }

      if (allTimes.isNotEmpty) {
        final now = DateTime.now();
        final nowMins = now.hour * 60 + now.minute;
        String? found;
        int minAfter = 9999;

        for (var t in allTimes) {
          final parts = t.split(':');
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
          final totalMins = h * 60 + m;
          if (totalMins > nowMins && totalMins < minAfter) {
            minAfter = totalMins;
            found = t;
          }
        }

        if (found != null) {
          nextReminder = TimeUtils.formatString(found, userData.is24HourFormat);
        } else {
          final first = allTimes.first;
          nextReminder = 'Tmr ${TimeUtils.formatString(first, userData.is24HourFormat)}';
        }
      }

      await HomeWidget.saveWidgetData<String>('next_reminder', nextReminder);
    } catch (_) {}
  }

  // ── Full updateWidgetData — called from app foreground only ────
  static Future<void> updateWidgetData(UserData userData,
      {List<DrinkLog>? logs, bool isBackground = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      int displayStreak = userData.streak;
      if (userData.drunk >= userData.goal) displayStreak++;

      final isPro = prefs.getBool('isPremium') ?? false;

      await Future.wait([
        HomeWidget.saveWidgetData<int>('intake', userData.drunk),
        HomeWidget.saveWidgetData<int>('goal', userData.goal),
        HomeWidget.saveWidgetData<int>('streak', displayStreak),
        HomeWidget.saveWidgetData<String>('volume_unit', userData.volumeUnit),
        HomeWidget.saveWidgetData<bool>(
            'is_24_hour_format', userData.is24HourFormat ?? false),
        HomeWidget.saveWidgetData<bool>('is_premium', isPro),
      ]);

      if (logs != null) {
        final todayStr = DateTime.now().toIso8601String().split('T')[0];
        final todayLogs = logs.where((l) => l.date == todayStr).toList();
        final lastAddedMl = todayLogs.isNotEmpty ? todayLogs.first.ml : 0;
        final stackStr = todayLogs.map((e) => '${e.ml}').join(',');

        await Future.wait([
          HomeWidget.saveWidgetData<int>('last_added_ml', lastAddedMl),
          HomeWidget.saveWidgetData<String>('widget_add_stack', stackStr),
        ]);

        await _writeHourlyData(prefs, userData, logs);
        await _writeWeeklyData(prefs, userData, logs);
      }

      await _writeNextReminder(prefs, userData);
      await _triggerAllWidgets();
    } catch (_) {}
  }

  // ── Premium-only sync ──────────────────────────────────────────
  static Future<void> syncPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPro = prefs.getBool('isPremium') ?? false;
      await HomeWidget.saveWidgetData<bool>('is_premium', isPro);
      await _triggerAllWidgets();
    } catch (_) {}
  }
}
