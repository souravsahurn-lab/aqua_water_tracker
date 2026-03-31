import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';
import '../models/drink_log.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';

class HydrationProvider extends ChangeNotifier with WidgetsBindingObserver {
  UserData _userData = UserData();
  List<DrinkLog> _logs = [];

  int _setupStep = 0;
  bool _isInit = false;
  bool _isSetupComplete = false;
  bool _remindersInitialized = false;

  HydrationProvider() {
    WidgetsBinding.instance.addObserver(this);
    _loadFromPrefs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// When the app comes back to foreground, re-sync from SharedPreferences
  /// in case the widget background callback updated the data.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInit) {
      _syncFromWidget();
    }
  }

  /// Lightweight sync: only re-reads if intake changed externally (widget).
  Future<void> _syncFromWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Force a fresh read from disk
      await prefs.reload();
      final userDataStr = prefs.getString('userData');
      if (userDataStr == null) return;

      final freshData = UserData.fromJson(jsonDecode(userDataStr));
      // Only apply if the intake value differs (widget added water)
      if (freshData.drunk != _userData.drunk) {
        _userData.drunk = freshData.drunk;

        // Also reload logs since the widget callback adds entries
        final logsStr = prefs.getString('logs');
        if (logsStr != null) {
          final List<dynamic> decoded = jsonDecode(logsStr);
          _logs = decoded.map((l) => DrinkLog.fromJson(l)).toList();
        }

        // Push the synced state back to the widget for consistency
        await WidgetService.updateWidgetData(_userData);
        super.notifyListeners(); // Use super to avoid re-saving to prefs
      }
    } catch (_) {}
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    final userDataStr = prefs.getString('userData');
    if (userDataStr != null) {
      try {
        _userData = UserData.fromJson(jsonDecode(userDataStr));
      } catch (e) {
        // Fallback
      }
    }

    final logsStr = prefs.getString('logs');
    if (logsStr != null) {
      try {
        final List<dynamic> decodedObj = jsonDecode(logsStr);
        _logs = decodedObj.map((l) => DrinkLog.fromJson(l)).toList();
      } catch (e) {
        // Fallback
      }
    }

    _setupStep = prefs.getInt('setupStep') ?? 0;
    _isSetupComplete = prefs.getBool('isSetupComplete') ?? false;
    _remindersInitialized = prefs.getBool('remindersInitialized') ?? false;

    // Backward compatibility generation for older version where this flag didn't exist
    if (!_remindersInitialized && _userData.customReminderTimes.isEmpty && _userData.wakeTime.isNotEmpty) {
      _regenerateSmartTimes();
      _remindersInitialized = true;
      prefs.setBool('remindersInitialized', true);
    }

    _isInit = true;
    _checkDailyReset();
    _updateReminders();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    if (!_isInit) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(_userData.toJson()));
    await prefs.setString('logs', jsonEncode(_logs.map((e) => e.toJson()).toList()));
    await prefs.setInt('setupStep', _setupStep);
    await prefs.setBool('isSetupComplete', _isSetupComplete);
    await prefs.setBool('remindersInitialized', _remindersInitialized);
    await WidgetService.updateWidgetData(_userData, logs: _logs);
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _saveToPrefs();
  }
  String _activeNav = 'dashboard';
  bool _showCustomLog = false;
  String _statPeriod = 'week';

  UserData get userData => _userData;
  List<DrinkLog> get logs => _logs;
  int get setupStep => _setupStep;
  bool get isSetupComplete => _isSetupComplete;
  String get activeNav => _activeNav;
  bool get showCustomLog => _showCustomLog;
  String get statPeriod => _statPeriod;
  bool get isInit => _isInit;

  bool get isStepValid {
    switch (_setupStep) {
      case 0: // name
        return _userData.name.trim().isNotEmpty;
      case 1: // gender
        return _userData.gender.isNotEmpty;
      case 2: // stats
        return _userData.age > 0 && _userData.weight > 0 && _userData.height > 0;
      case 3: // activity
        return _userData.activity.isNotEmpty;
      case 4: // schedule
        return _userData.wakeTime.isNotEmpty && _userData.sleepTime.isNotEmpty;
      default:
        return true;
    }
  }

  int get pct => (_userData.goal > 0)
      ? ((_userData.drunk / _userData.goal) * 100).round()
      : 0;
  int get remaining => (_userData.goal - _userData.drunk).clamp(0, _userData.goal);

  // ═══════════════════════════════════════════════════════════════════
  // Daily Reset & Streak Logic
  // ═══════════════════════════════════════════════════════════════════

  void _checkDailyReset() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_userData.lastActiveDate != today) {
      try {
        final lastDate = DateTime.parse(_userData.lastActiveDate);
        final currentDate = DateTime.now();
        final diff = currentDate.difference(lastDate).inDays;
        
        if (diff == 1) {
          // Yesterday: check if they met the goal yesterday
          final yesterdayStr = lastDate.toIso8601String().split('T')[0];
          final yesterdayIntake = _logs
              .where((l) => l.date == yesterdayStr)
              .fold(0, (sum, l) => sum + l.ml);
          if (yesterdayIntake >= _userData.goal) {
            _userData.streak++;
          } else {
            _userData.streak = 0;
          }
        } else if (diff > 1) {
          _userData.streak = 0;
        }
      } catch (e) {
        _userData.streak = 0;
      }
      
      _userData.drunk = 0;
      _userData.lastActiveDate = today;
      _saveToPrefs();
    }
  }

  /// The effective streak to display: if they met today's goal, add 1 to the base streak
  int get displayStreak {
    if (_userData.drunk >= _userData.goal) {
      return _userData.streak + 1;
    }
    return _userData.streak;
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    if (hour < 21) return 'Good Evening,';
    return 'Good Night,';
  }

  // ═══════════════════════════════════════════════════════════════════
  // Goal Calculation
  // ═══════════════════════════════════════════════════════════════════

  void _recalculateGoalIfAuto() {
    if (!_userData.customGoal) {
      _userData.goal = UserData.calculateGoal(
        weight: _userData.weight,
        height: _userData.height,
        activity: _userData.activity,
        gender: _userData.gender,
      );
    }
  }

  /// Returns the recommended goal based on current profile
  int get recommendedGoal => UserData.calculateGoal(
    weight: _userData.weight,
    height: _userData.height,
    activity: _userData.activity,
    gender: _userData.gender,
  );

  // ═══════════════════════════════════════════════════════════════════
  // Reminders
  // ═══════════════════════════════════════════════════════════════════

  void _updateReminders() {
    if (!_isInit || !_isSetupComplete) return;

    final wParts = _userData.wakeTime.split(':');
    final sParts = _userData.sleepTime.split(':');

    final wakeTimeOfDay = TimeOfDay(
      hour: int.tryParse(wParts[0]) ?? 7,
      minute: int.tryParse(wParts.length > 1 ? wParts[1] : '0') ?? 0,
    );
    final sleepTimeOfDay = TimeOfDay(
      hour: int.tryParse(sParts[0]) ?? 22,
      minute: int.tryParse(sParts.length > 1 ? sParts[1] : '0') ?? 0,
    );

    // Always use customReminderTimes as the source of truth
    // If empty, auto-generate them first
    if (_userData.customReminderTimes.isEmpty) {
      _regenerateSmartTimes();
    }

    final customTimes = _userData.customReminderTimes.map((t) {
      final parts = t.split(':');
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );
    }).toList();

    NotificationService().scheduleReminders(
      wakeTime: wakeTimeOfDay,
      sleepTime: sleepTimeOfDay,
      intervalMin: _userData.reminderIntervalMin,
      enabled: _userData.reminders,
      soundEnabled: _userData.sound,
      vibrationEnabled: _userData.vibration,
      soundName: _userData.notificationSound,
      customTimes: customTimes,
    );
  }

  /// Auto-generate smart reminder times based on goal and schedule
  void _regenerateSmartTimes() {
    try {
      final wParts = _userData.wakeTime.split(':');
      final sParts = _userData.sleepTime.split(':');
      final wakeH = int.parse(wParts[0]);
      final wakeM = int.parse(wParts[1]);
      final sleepH = int.parse(sParts[0]);
      final sleepM = int.parse(sParts[1]);

      final now = DateTime.now();
      DateTime wake = DateTime(now.year, now.month, now.day, wakeH, wakeM);
      DateTime sleep = DateTime(now.year, now.month, now.day, sleepH, sleepM);
      if (sleep.isBefore(wake)) sleep = sleep.add(const Duration(days: 1));

      int interval;
      if (_userData.smartReminders) {
        final numReminders = (_userData.goal / 250).ceil().clamp(4, 20);
        final awakeMinutes = sleep.difference(wake).inMinutes;
        interval = (awakeMinutes / numReminders).floor().clamp(30, 180);
      } else {
        interval = _userData.reminderIntervalMin;
      }

      List<String> times = [];
      DateTime current = wake;
      while (current.isBefore(sleep) && times.length < 30) {
        times.add('${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}');
        current = current.add(Duration(minutes: interval));
      }
      _userData.customReminderTimes = times;
    } catch (_) {}
  }

  /// Public method: regenerate reminders from scratch (smart recalculate)
  void regenerateSmartReminders() {
    _regenerateSmartTimes();
    _updateReminders();
    _saveToPrefs();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════
  // Analytics Computed Data
  // ═══════════════════════════════════════════════════════════════════

  /// Structurally generates 2-hour time slots from wake to sleep
  List<int> _getHourlySlotStarts() {
    int wakeH = 7;
    int sleepH = 22;
    try {
      wakeH = int.parse(_userData.wakeTime.split(':')[0]);
      sleepH = int.parse(_userData.sleepTime.split(':')[0]);
    } catch (_) {}

    if (sleepH <= wakeH) sleepH += 24;

    List<int> slots = [];
    for (int h = wakeH; h < sleepH; h += 2) {
      slots.add(h % 24);
    }
    
    // Add "Late night" if logs exist after sleep time
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayLogs = _logs.where((e) => e.date == today);
    
    // Check for logs outside the range (before wake or after sleep)
    bool hasEarly = false;
    bool hasLate = false;
    for (var l in todayLogs) {
      try {
        final logH = int.parse(l.time.split(':')[0]);
        if (logH < wakeH) hasEarly = true;
        if (logH >= sleepH % 24 && logH >= (sleepH - 24).abs()) {
           // This logic is a bit complex for wrap-around, 
           // let's just check if it's covered by existing slots
           bool covered = false;
           for (var s in slots) {
             if (logH >= s && logH < s + 2) covered = true;
           }
           if (!covered) hasLate = true;
        }
      } catch (_) {}
    }

    if (hasEarly && !slots.contains((wakeH - 2) % 24)) {
      slots.insert(0, (wakeH - 2) % 24);
    }
    if (hasLate) {
      slots.add(sleepH % 24);
    }

    if (slots.isEmpty) slots = [7, 9, 11, 13, 15, 17, 19, 21];
    return slots;
  }

  /// Labels for the hourly bar chart (per 2-hour slot range)
  List<String> getHourlyLabels() {
    final starts = _getHourlySlotStarts();
    return starts.map((h) {
      final hEnd = (h + 2) % 24;

      final h12S = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      final suffixS = h < 12 ? 'a' : 'p';

      final h12E = hEnd == 0 ? 12 : (hEnd > 12 ? hEnd - 12 : hEnd);
      final suffixE = hEnd < 12 ? 'a' : 'p';

      if (suffixS == suffixE) {
        return '$h12S-$h12E$suffixE';
      }
      return '$h12S$suffixS-$h12E$suffixE';
    }).toList();
  }

  /// Highlight the slot containing the current hour
  int getHourlyHighlightIndex() {
    final starts = _getHourlySlotStarts();
    final nowH = DateTime.now().hour;
    int bestIdx = 0;
    for (int i = 0; i < starts.length; i++) {
       if (nowH >= starts[i]) bestIdx = i;
    }
    return bestIdx;
  }

  List<double> getBarData(String period) {
    if (period == 'day') {
      final slots = _getHourlySlotStarts();
      List<double> data = List.filled(slots.length, 0.0);
      final today = DateTime.now().toIso8601String().split('T')[0];
      for (var l in _logs.where((e) => e.date == today)) {
        try {
          final logH = int.parse(l.time.split(':')[0]);
          int targetSlot = 0;
          for (int i = 0; i < slots.length; i++) {
             if (logH >= slots[i]) targetSlot = i;
          }
          data[targetSlot] += l.ml;
        } catch (_) {}
      }
      return data;
    } else if (period == 'week') {
      List<double> data = List.filled(7, 0.0);
      final now = DateTime.now();
      final diff = now.weekday == 7 ? 0 : now.weekday;
      final sunday = now.subtract(Duration(days: diff));
      for (int i = 0; i < 7; i++) {
        final d = sunday.add(Duration(days: i)).toIso8601String().split('T')[0];
        final sum = _logs.where((l) => l.date == d).fold(0, (p, c) => p + c.ml);
        data[i] = sum.toDouble();
      }
      return data;
    } else {
      List<double> data = List.filled(13, 0.0);
      final now = DateTime.now();
      for (int i = 0; i < 13; i++) {
        final d = now.subtract(Duration(days: (12 - i) * 2)).toIso8601String().split('T')[0];
        final sum = _logs.where((l) => l.date == d).fold(0, (p, c) => p + c.ml);
        data[i] = sum.toDouble();
      }
      return data;
    }
  }

  /// Average daily intake for the given period
  int getAverageIntake(String period) {
    final data = getBarData(period);
    final nonZero = data.where((d) => d > 0).toList();
    if (nonZero.isEmpty) return 0;
    return (nonZero.reduce((a, b) => a + b) / nonZero.length).round();
  }

  /// Best (highest) intake for the given period
  int getBestIntake(String period) {
    final data = getBarData(period);
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a > b ? a : b).round();
  }

  /// Goal hit count string like "5/7" for the period
  String getGoalHitStr(String period) {
    if (period == 'day') {
      // For day view: how many time blocks had some intake
      final data = getBarData(period);
      final filled = data.where((d) => d > 0).length;
      return '$filled/${data.length}';
    } else if (period == 'week') {
      final now = DateTime.now();
      final diff = now.weekday == 7 ? 0 : now.weekday;
      final sunday = now.subtract(Duration(days: diff));
      int hit = 0;
      for (int i = 0; i < 7; i++) {
        final d = sunday.add(Duration(days: i)).toIso8601String().split('T')[0];
        final sum = _logs.where((l) => l.date == d).fold(0, (p, c) => p + c.ml);
        if (sum >= _userData.goal) hit++;
      }
      return '$hit/7';
    } else {
      final now = DateTime.now();
      int hit = 0;
      int total = 0;
      for (int i = 0; i < 30; i++) {
        final d = now.subtract(Duration(days: 29 - i)).toIso8601String().split('T')[0];
        final sum = _logs.where((l) => l.date == d).fold(0, (p, c) => p + c.ml);
        if (sum > 0) total++;
        if (sum >= _userData.goal) hit++;
      }
      return '$hit/${total > 0 ? total : 30}';
    }
  }

  /// Calculate trend percentage: compare current period avg vs previous period avg
  double getTrendPercentage(String period) {
    final now = DateTime.now();
    double currentAvg = 0;
    double prevAvg = 0;

    if (period == 'day') {
      // Today vs yesterday
      final today = now.toIso8601String().split('T')[0];
      final yesterday = now.subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
      final todaySum = _logs.where((l) => l.date == today).fold(0, (p, c) => p + c.ml);
      final yesterdaySum = _logs.where((l) => l.date == yesterday).fold(0, (p, c) => p + c.ml);
      currentAvg = todaySum.toDouble();
      prevAvg = yesterdaySum.toDouble();
    } else if (period == 'week') {
      // This week vs last week (Daily Averages)
      final diff = now.weekday == 7 ? 0 : now.weekday;
      final thisSunday = now.subtract(Duration(days: diff));
      final lastSunday = thisSunday.subtract(const Duration(days: 7));
      
      double thisWeekTotal = 0;
      int thisWeekDays = 0;
      for (int i = 0; i < 7; i++) {
        final dDate = thisSunday.add(Duration(days: i));
        final d = dDate.toIso8601String().split('T')[0];
        final sum = _logs.where((l) => l.date == d).fold(0, (p, c) => p + c.ml);
        thisWeekTotal += sum;
        if (dDate.isBefore(now) || d == now.toIso8601String().split('T')[0]) {
          thisWeekDays++;
        }
      }
      
      double lastWeekTotal = 0;
      for (int i = 0; i < 7; i++) {
        final pd = lastSunday.add(Duration(days: i)).toIso8601String().split('T')[0];
        lastWeekTotal += _logs.where((l) => l.date == pd).fold(0, (p, c) => p + c.ml);
      }
      
      currentAvg = thisWeekDays > 0 ? thisWeekTotal / thisWeekDays : 0;
      prevAvg = lastWeekTotal / 7;
    } else {
      // This month vs last month  
      for (int i = 0; i < 30; i++) {
        final d = now.subtract(Duration(days: i)).toIso8601String().split('T')[0];
        currentAvg += _logs.where((l) => l.date == d).fold(0, (p, c) => p + c.ml);
        final pd = now.subtract(Duration(days: 30 + i)).toIso8601String().split('T')[0];
        prevAvg += _logs.where((l) => l.date == pd).fold(0, (p, c) => p + c.ml);
      }
    }

    if (prevAvg == 0) return currentAvg > 0 ? 100.0 : 0.0;
    return ((currentAvg - prevAvg) / prevAvg * 100).roundToDouble();
  }

  /// Hydration score (0-100) based on last 7 days
  int get hydrationScore {
    final now = DateTime.now();
    int daysMetGoal = 0;
    double totalCompletionPct = 0;

    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i)).toIso8601String().split('T')[0];
      final sum = _logs.where((l) => l.date == d).fold(0, (p, c) => p + c.ml);
      final pctDay = _userData.goal > 0 ? (sum / _userData.goal * 100).clamp(0, 100) : 0;
      totalCompletionPct += pctDay;
      if (sum >= _userData.goal) daysMetGoal++;
    }

    // Consistency: what % of last 7 days goal was met (0-40 points)
    final consistency = (daysMetGoal / 7 * 40).round();
    // Average completion % (0-40 points)
    final avgCompletion = (totalCompletionPct / 7 / 100 * 40).round();
    // Streak bonus (0-20 points)  
    final streakBonus = (_userData.streak.clamp(0, 10) * 2);

    return (consistency + avgCompletion + streakBonus).clamp(0, 100);
  }

  /// Hydration score label
  String get hydrationScoreLabel {
    final score = hydrationScore;
    if (score >= 85) return 'Excellent! 🌟';
    if (score >= 70) return 'Great! 🎉';
    if (score >= 50) return 'Good 👍';
    if (score >= 30) return 'Needs work 💪';
    return 'Keep going! 🚀';
  }

  /// Hydration score tip
  String get hydrationScoreTip {
    final score = hydrationScore;
    if (score >= 85) return "You're consistently hitting your daily goal. Amazing dedication!";
    if (score >= 70) return "You're doing great! Try to be more consistent to reach a perfect score.";
    if (score >= 50) return "Good effort! Try hitting your goal more consistently for a higher score.";
    if (score >= 30) return "You're building the habit. Set regular reminders to improve.";
    return "Start logging your water intake daily. Every glass counts!";
  }

  /// Returns which of the last 7 days had goal met (Mon-Sun order)
  List<bool> get weeklyGoalStatus {
    final now = DateTime.now();
    // Find the most recent Monday
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    List<bool> status = [];
    for (int i = 0; i < 7; i++) {
      final d = DateTime(monday.year, monday.month, monday.day + i)
          .toIso8601String()
          .split('T')[0];
      final sum = _logs.where((l) => l.date == d).fold(0, (p, c) => p + c.ml);
      // For future days, mark as false
      final dayDate = DateTime(monday.year, monday.month, monday.day + i);
      if (dayDate.isAfter(now)) {
        status.add(false);
      } else {
        status.add(sum >= _userData.goal);
      }
    }
    return status;
  }

  Map<String, int> getDrinkTypeBreakdown(String period, [DateTime? selectedDate]) {
    Iterable<DrinkLog> filteredLogs = [];
    final now = DateTime.now();

    if (period == 'day') {
      final todayStr = now.toIso8601String().split('T')[0];
      filteredLogs = _logs.where((e) => e.date == todayStr);
    } else if (period == 'week') {
      final diff = now.weekday == 7 ? 0 : now.weekday;
      final sunday = now.subtract(Duration(days: diff));
      final saturday = sunday.add(const Duration(days: 6));
      
      filteredLogs = _logs.where((e) {
        try {
          final logDate = DateTime.parse(e.date);
           final start = DateTime(sunday.year, sunday.month, sunday.day);
           final end = DateTime(saturday.year, saturday.month, saturday.day, 23, 59, 59);
           return logDate.isAfter(start.subtract(const Duration(seconds: 1))) && 
                  logDate.isBefore(end.add(const Duration(seconds: 1)));
        } catch (_) {
          return false;
        }
      });
    } else if (period == 'month' && selectedDate != null) {
      final dateStr = selectedDate.toIso8601String().split('T')[0];
      filteredLogs = _logs.where((e) => e.date == dateStr);
    }

    Map<String, int> breakdown = {};
    for (var l in filteredLogs) {
      breakdown[l.label] = (breakdown[l.label] ?? 0) + l.ml;
    }
    return breakdown;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Reminder Getters
  // ═══════════════════════════════════════════════════════════════════

  /// Always returns from customReminderTimes (source of truth)
  List<TimeOfDay> get generatedReminders {
    if (_userData.wakeTime.isEmpty || _userData.sleepTime.isEmpty) return [];

    // Only generate if they have NEVER been initialized.
    // This allows the user to delete ALL reminders (leaving list empty) without them auto-regenerating.
    if (!_remindersInitialized) {
      _regenerateSmartTimes();
      _remindersInitialized = true;
      _saveToPrefs();
    }

    return _userData.customReminderTimes.map((t) {
      final parts = t.split(':');
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );
    }).toList()
      ..sort((a, b) {
        if (a.hour != b.hour) return a.hour.compareTo(b.hour);
        return a.minute.compareTo(b.minute);
      });
  }

  String get nextReminderTimeStr {
    final now = TimeOfDay.now();
    for (var r in generatedReminders) {
      if (r.hour > now.hour || (r.hour == now.hour && r.minute > now.minute)) {
        final hr = r.hour == 0 ? 12 : (r.hour > 12 ? r.hour - 12 : r.hour);
        final min = r.minute.toString().padLeft(2, '0');
        final ampm = r.hour < 12 ? 'AM' : 'PM';
        return '$hr:$min $ampm';
      }
    }
    return '--:--';
  }

  /// The effective interval in minutes (for display)
  int get effectiveInterval {
    if (_userData.smartReminders) {
      try {
        final wParts = _userData.wakeTime.split(':');
        final sParts = _userData.sleepTime.split(':');
        final now = DateTime.now();
        DateTime wake = DateTime(now.year, now.month, now.day, int.parse(wParts[0]), int.parse(wParts[1]));
        DateTime sleep = DateTime(now.year, now.month, now.day, int.parse(sParts[0]), int.parse(sParts[1]));
        if (sleep.isBefore(wake)) sleep = sleep.add(const Duration(days: 1));
        final numReminders = (_userData.goal / 250).ceil().clamp(4, 20);
        return (sleep.difference(wake).inMinutes / numReminders).floor().clamp(30, 180);
      } catch (_) {
        return 60;
      }
    }
    return _userData.reminderIntervalMin;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Actions
  // ═══════════════════════════════════════════════════════════════════

  void updateReminderInterval(int mins) {
    _userData.reminderIntervalMin = mins;
    // Regenerate times with new interval
    _regenerateSmartTimes();
    _updateReminders();
    notifyListeners();
  }

  void drinkWater(int ml, {String label = 'Water', String icon = '💧'}) {
    _userData.drunk += ml;
    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _logs.insert(
        0,
        DrinkLog(
            date: DateTime.now().toIso8601String().split('T')[0],
            time: timeStr,
            icon: icon,
            label: label,
            ml: ml));
    notifyListeners();
  }

  void undoDrink(int index) {
    if (index >= 0 && index < _logs.length) {
      final removed = _logs.removeAt(index);
      _userData.drunk = (_userData.drunk - removed.ml).clamp(0, 99999);
      notifyListeners();
    }
  }

  void clearTodayLogs() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final initialCount = _logs.length;
    _logs.removeWhere((log) => log.date == today);
    
    if (_logs.length != initialCount) {
      _userData.drunk = 0;
      notifyListeners();
    }
  }

  void updateName(String name) {
    _userData.name = name;
    _saveToPrefs();
    notifyListeners();
  }

  void updateGender(String gender) {
    _userData.gender = gender;
    _recalculateGoalIfAuto();
    _saveToPrefs();
    notifyListeners();
  }

  void updateWeight(int weight) {
    _userData.weight = weight;
    _recalculateGoalIfAuto();
    _saveToPrefs();
    notifyListeners();
  }

  void updateHeight(int height) {
    _userData.height = height;
    _recalculateGoalIfAuto();
    _saveToPrefs();
    notifyListeners();
  }

  void updateAge(int age) {
    _userData.age = age;
    _saveToPrefs();
    notifyListeners();
  }

  void updateActivity(String activity) {
    _userData.activity = activity;
    _recalculateGoalIfAuto();
    _saveToPrefs();
    notifyListeners();
  }

  void updateWakeTime(String time) {
    _userData.wakeTime = time;
    _regenerateSmartTimes();
    _updateReminders();
    _saveToPrefs();
    notifyListeners();
  }

  void updateSleepTime(String time) {
    _userData.sleepTime = time;
    _regenerateSmartTimes();
    _updateReminders();
    _saveToPrefs();
    notifyListeners();
  }

  void updateGoal(int goal) {
    _userData.goal = goal;
    _userData.customGoal = true;
    _updateReminders(); // smart reminders depend on goal
    _saveToPrefs();
    notifyListeners();
  }

  void resetGoalToRecommended() {
    _userData.customGoal = false;
    _recalculateGoalIfAuto();
    _updateReminders();
    _saveToPrefs();
    notifyListeners();
  }

  void toggleReminders(bool val) {
    _userData.reminders = val;
    _updateReminders();
    _saveToPrefs();
    notifyListeners();
  }

  void toggleSound(bool val) {
    _userData.sound = val;
    _updateReminders();
    _saveToPrefs();
    notifyListeners();
  }

  void toggleVibration(bool val) {
    _userData.vibration = val;
    _updateReminders();
    _saveToPrefs();
    notifyListeners();
  }

  void toggleDarkMode(bool val) {
    _userData.darkMode = val;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleSmartReminders(bool val) {
    _userData.smartReminders = val;
    // Always regenerate times when toggling smart mode
    _regenerateSmartTimes();
    _updateReminders();
    _saveToPrefs();
    notifyListeners();
  }

  void updateNotificationSound(String sound) {
    _userData.notificationSound = sound;
    _updateReminders();
    _saveToPrefs();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════
  // Custom Reminder Management (for manual mode)
  // ═══════════════════════════════════════════════════════════════════

  void addCustomReminder(TimeOfDay time) {
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    if (!_userData.customReminderTimes.contains(timeStr)) {
      _userData.customReminderTimes.add(timeStr);
      _userData.customReminderTimes.sort();
      _updateReminders();
      notifyListeners();
    }
  }

  void removeCustomReminder(int index) {
    if (index >= 0 && index < _userData.customReminderTimes.length) {
      _userData.customReminderTimes.removeAt(index);
      _updateReminders();
      notifyListeners();
    }
  }

  void updateCustomReminder(int index, TimeOfDay time) {
    if (index >= 0 && index < _userData.customReminderTimes.length) {
      _userData.customReminderTimes[index] =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _userData.customReminderTimes.sort();
      _updateReminders();
      notifyListeners();
    }
  }

  /// Initialize custom reminders from the auto-generated ones (when switching to manual)
  void initCustomRemindersFromAuto() {
    if (_userData.customReminderTimes.isEmpty) {
      // Copy current auto-generated reminders as starting point
      final autoReminders = generatedReminders;
      _userData.customReminderTimes = autoReminders.map((t) {
        return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
      }).toList();
      _saveToPrefs();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Setup
  // ═══════════════════════════════════════════════════════════════════

  void setSetupStep(int step) {
    _setupStep = step;
    notifyListeners();
  }

  void nextSetupStep() {
    if (isStepValid) {
      _setupStep++;
      notifyListeners();
    }
  }

  void completeSetup() {
    if (isStepValid) {
      _isSetupComplete = true;
      // Calculate goal based on profile
      _recalculateGoalIfAuto();
      _updateReminders();
      notifyListeners();
    }
  }

  void prevSetupStep() {
    if (_setupStep > 0) {
      _setupStep--;
      notifyListeners();
    }
  }

  void setActiveNav(String nav) {
    _activeNav = nav;
    notifyListeners();
  }

  void toggleCustomLog() {
    _showCustomLog = !_showCustomLog;
    notifyListeners();
  }

  void setStatPeriod(String period) {
    _statPeriod = period;
    notifyListeners();
  }

  Future<void> resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _userData = UserData();
    _logs = [];
    _setupStep = 0;
    _isSetupComplete = false;
    _activeNav = 'dashboard';
    _showCustomLog = false;
    _statPeriod = 'week';
    _isInit = true;
    notifyListeners();
  }

  /// Today's logs only
  List<DrinkLog> get todayLogs {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _logs.where((l) => l.date == today).toList();
  }

  /// Generate shareable text based on period
  String? getShareData(String period, {DateTime? customDate}) {
    final now = DateTime.now();
    List<DrinkLog> filteredLogs = [];
    String title = "";

    if (period == 'today') {
      final todayStr = now.toIso8601String().split('T')[0];
      filteredLogs = _logs.where((l) => l.date == todayStr).toList();
      title = "Today's Intake (${todayStr})";
    } else if (period == 'week') {
      final diff = now.weekday == 7 ? 0 : now.weekday;
      final sunday = now.subtract(Duration(days: diff));
      final start = DateTime(sunday.year, sunday.month, sunday.day);
      filteredLogs = _logs.where((l) {
        try {
          final d = DateTime.parse(l.date);
          return d.isAfter(start.subtract(const Duration(seconds: 1)));
        } catch (_) { return false; }
      }).toList();
      title = "Last 7 Days (from ${start.toIso8601String().split('T')[0]})";
    } else if (period == 'month') {
      filteredLogs = _logs.where((l) {
        try {
          final d = DateTime.parse(l.date);
          return d.year == now.year && d.month == now.month;
        } catch (_) { return false; }
      }).toList();
      title = "Intake for ${now.month}/${now.year}";
    } else if (period == 'custom' && customDate != null) {
      final dateStr = customDate.toIso8601String().split('T')[0];
      filteredLogs = _logs.where((l) => l.date == dateStr).toList();
      title = "Intake for ${dateStr}";
    }

    if (filteredLogs.isEmpty) return null;

    final buffer = StringBuffer();
    buffer.writeln('Aqua Water Tracker — Hydration Report');
    buffer.writeln('Report: $title');
    buffer.writeln('Generated: ${now.toString().split('.')[0]}');
    buffer.writeln('');
    buffer.writeln('Profile:');
    buffer.writeln('  User: ${_userData.name}');
    buffer.writeln('  Goal: ${_userData.goal}ml');
    buffer.writeln('  Total Drunk: ${filteredLogs.fold(0, (sum, l) => sum + l.ml)}ml');
    buffer.writeln('');
    buffer.writeln('Detailed Logs:');
    for (var log in filteredLogs.reversed) {
      buffer.writeln('  [${log.date} ${log.time}] — ${log.label}: ${log.ml}ml');
    }
    buffer.writeln('');
    buffer.writeln('Stay hydrated with Aqua 💧');
    return buffer.toString();
  }
}
