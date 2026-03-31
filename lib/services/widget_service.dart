import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_data.dart';
import '../models/drink_log.dart';

/// Top-level background callback invoked when a widget button is tapped.
/// Runs in its own isolate — no access to Provider or app state.
@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? uri) async {
  if (uri == null) return;

  if (uri.host == 'add') {
    final amount = int.tryParse(uri.pathSegments.firstOrNull ?? '0') ?? 0;
    if (amount <= 0) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // CRITICAL: Force read from disk in the isolate

    // ── Read current Flutter-side data ──
    UserData userData = UserData();
    final userDataStr = prefs.getString('userData');
    if (userDataStr != null) {
      try {
        userData = UserData.fromJson(jsonDecode(userDataStr));
      } catch (_) {}
    }

    // ── Update intake ──
    userData.drunk += amount;

    // ── Add drink log ──
    List<DrinkLog> logs = [];
    final logsStr = prefs.getString('logs');
    if (logsStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(logsStr);
        logs = decoded.map((l) => DrinkLog.fromJson(l)).toList();
      } catch (_) {}
    }

    final now = DateTime.now();
    logs.insert(
      0,
      DrinkLog(
        date: now.toIso8601String().split('T')[0],
        time:
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        icon: '💧',
        label: 'Water',
        ml: amount,
      ),
    );

    // ── Persist to Flutter prefs ──
    await prefs.setString('userData', jsonEncode(userData.toJson()));
    await prefs.setString(
        'logs', jsonEncode(logs.map((e) => e.toJson()).toList()));

    // ── Sync widget prefs ──
    // Pass isBackground: true so the widget doesn't get downgraded by stale isolate data.
    await WidgetService.updateWidgetData(userData, logs: logs, isBackground: true);
  }

  if (uri.host == 'undo') {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    UserData userData = UserData();
    final userDataStr = prefs.getString('userData');
    if (userDataStr != null) {
      try { userData = UserData.fromJson(jsonDecode(userDataStr)); } catch (_) {}
    }

    List<DrinkLog> logs = [];
    final logsStr = prefs.getString('logs');
    if (logsStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(logsStr);
        logs = decoded.map((l) => DrinkLog.fromJson(l)).toList();
      } catch (_) {}
    }

    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    if (logs.isNotEmpty && logs.first.date == todayStr) {
      final removed = logs.removeAt(0);
      userData.drunk -= removed.ml;
      if (userData.drunk < 0) userData.drunk = 0;

      await prefs.setString('userData', jsonEncode(userData.toJson()));
      await prefs.setString('logs', jsonEncode(logs.map((e) => e.toJson()).toList()));
      await WidgetService.updateWidgetData(userData, logs: logs, isBackground: true);
    }
  }
}

class WidgetService {
  /// Call once on app boot to register the background callback.
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('');
    await HomeWidget.registerInteractivityCallback(interactiveCallback);
  }

  /// Push the latest data into widget SharedPreferences and refresh the widget.
  static Future<void> updateWidgetData(UserData userData, {List<DrinkLog>? logs, bool isBackground = false}) async {
    try {
      if (isBackground) {
          int? currentWidgetIntake = await HomeWidget.getWidgetData<int>('intake');
          if (currentWidgetIntake != null && userData.drunk < currentWidgetIntake) {
              return; 
          }
      }

      // Calculate display streak
      int displayStreak = userData.streak;
      if (userData.drunk >= userData.goal) {
        displayStreak++;
      }

      await HomeWidget.saveWidgetData<int>('intake', userData.drunk);
      await HomeWidget.saveWidgetData<int>('goal', userData.goal);
      await HomeWidget.saveWidgetData<int>('streak', displayStreak);

      int lastAddedMl = 0;
      if (logs != null && logs.isNotEmpty) {
        final todayStr = DateTime.now().toIso8601String().split('T')[0];
        if (logs.first.date == todayStr) {
          lastAddedMl = logs.first.ml;
        }
      }
      await HomeWidget.saveWidgetData<int>('last_added_ml', lastAddedMl);

      // Hourly data aggregation for 4x3 Widget
      if (logs != null) {
        final today = DateTime.now().toIso8601String().split('T')[0];
        final todayLogs = logs.where((l) => l.date == today).toList();

        // 1. Calculate slots (reusing logic from provider for consistency)
        int wakeH = 7;
        int sleepH = 22;
        try {
          wakeH = int.parse(userData.wakeTime.split(':')[0]);
          sleepH = int.parse(userData.sleepTime.split(':')[0]);
        } catch (_) {}

        if (sleepH <= wakeH) sleepH += 24;

        List<int> slots = [];
        for (int h = wakeH; h < sleepH; h += 2) {
          slots.add(h % 24);
        }

        // 2. Add extra slots if logs exist outside range
        bool hasEarly = false;
        bool hasLate = false;
        for (var l in todayLogs) {
          try {
            final logH = int.parse(l.time.split(':')[0]);
            if (logH < wakeH) hasEarly = true;
            if (logH >= sleepH % 24 && logH >= (sleepH - 24).abs()) {
               bool covered = false;
               for (var s in slots) {
                 if (logH >= s && logH < s + 2) covered = true;
               }
               if (!covered) hasLate = true;
            }
          } catch (_) {}
        }
        if (hasEarly && !slots.contains((wakeH - 2) % 24)) slots.insert(0, (wakeH - 2) % 24);
        if (hasLate) slots.add(sleepH % 24);
        if (slots.isEmpty) slots = [7, 9, 11, 13, 15, 17, 19, 21];

        // 3. Aggregate totals
        final List<int> values = List.filled(slots.length, 0);
        final List<String> labels = [];
        for (int i = 0; i < slots.length; i++) {
          final h = slots[i];
          // Range label e.g., "7-9"
          final h12Start = h == 0 ? 12 : (h > 12 ? h - 12 : h);
          final endH = (h + 2) % 24;
          final h12End = endH == 0 ? 12 : (endH > 12 ? endH - 12 : endH);
          labels.add('$h12Start-$h12End');

          for (var l in todayLogs) {
            try {
              final logH = int.parse(l.time.split(':')[0]);
              if (logH >= h && logH < h + 2) {
                values[i] += l.ml;
              }
            } catch (_) {}
          }
        }

        await HomeWidget.saveWidgetData<String>('hourly_vals', values.join(','));
        await HomeWidget.saveWidgetData<String>('hourly_labels', labels.join(','));

        // Weekly data aggregation for 4x3 Weekly Widget
        final List<int> weeklyVals = [];
        final List<String> weeklyLabelsTop = [];
        final List<String> weeklyLabelsBottom = [];
        final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

        final DateTime now = DateTime.now();
        for (int i = 6; i >= 0; i--) {
          final targetDate = now.subtract(Duration(days: i));
          final dateStr = targetDate.toIso8601String().split('T')[0];
          
          final dayLogs = logs.where((l) => l.date == dateStr).toList();
          int dailyTotal = 0;
          for (var l in dayLogs) {
            dailyTotal += l.ml;
          }
          weeklyVals.add(dailyTotal);
          weeklyLabelsTop.add(weekDays[targetDate.weekday - 1]);
          weeklyLabelsBottom.add('${targetDate.day}');
        }
        await HomeWidget.saveWidgetData<String>('weekly_vals', weeklyVals.join(','));
        await HomeWidget.saveWidgetData<String>('weekly_labels_top', weeklyLabelsTop.join(','));
        await HomeWidget.saveWidgetData<String>('weekly_labels_bottom', weeklyLabelsBottom.join(','));
      }

      // Next reminder
      String nextReminder = '--:--';
      if (userData.customReminderTimes.isNotEmpty) {
        final nowH = DateTime.now().hour;
        final nowM = DateTime.now().minute;
        for (var t in userData.customReminderTimes) {
          final parts = t.split(':');
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
          if (h > nowH || (h == nowH && m > nowM)) {
            final hr = h == 0 ? 12 : (h > 12 ? h - 12 : h);
            final min = m.toString().padLeft(2, '0');
            final ampm = h < 12 ? 'AM' : 'PM';
            nextReminder = '$hr:$min $ampm';
            break;
          }
        }
        if (nextReminder == '--:--') {
          final t = userData.customReminderTimes.first;
          final parts = t.split(':');
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
          final hr = h == 0 ? 12 : (h > 12 ? h - 12 : h);
          final min = m.toString().padLeft(2, '0');
          final ampm = h < 12 ? 'AM' : 'PM';
          nextReminder = 'Tmr $hr:$min $ampm';
        }
      }
      await HomeWidget.saveWidgetData<String>('next_reminder', nextReminder);

      // Trigger update for both widgets
      await HomeWidget.updateWidget(name: 'WaterWidgetReceiver', androidName: 'WaterWidgetReceiver');
      await HomeWidget.updateWidget(name: 'HourlyWidgetReceiver', androidName: 'HourlyWidgetReceiver');
      await HomeWidget.updateWidget(name: 'WeeklyWidgetReceiver', androidName: 'WeeklyWidgetReceiver');
      await HomeWidget.updateWidget(name: 'BottleWidgetReceiver', androidName: 'BottleWidgetReceiver');
      await HomeWidget.updateWidget(name: 'GridWidgetReceiver', androidName: 'GridWidgetReceiver');
    } catch (_) { }
  }
}
