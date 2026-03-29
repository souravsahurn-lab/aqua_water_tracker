import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';
import '../models/drink_log.dart';
import '../services/notification_service.dart';

class HydrationProvider extends ChangeNotifier {
  UserData _userData = UserData();
  List<DrinkLog> _logs = [];

  int _setupStep = 0;
  bool _isInit = false;
  bool _isSetupComplete = false;

  HydrationProvider() {
    _loadFromPrefs();
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

  void _checkDailyReset() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_userData.lastActiveDate != today) {
      try {
        final lastDate = DateTime.parse(_userData.lastActiveDate);
        final currentDate = DateTime.now();
        final diff = currentDate.difference(lastDate).inDays;
        
        if (diff == 1) {
          if (_userData.drunk >= _userData.goal) {
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

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    if (hour < 21) return 'Good Evening,';
    return 'Good Night,';
  }

  void _updateReminders() {
    if (!_isInit || !_isSetupComplete) return;

    final wParts = _userData.wakeTime.split(':');
    final sParts = _userData.sleepTime.split(':');

    NotificationService().scheduleReminders(
      wakeTime: TimeOfDay(
        hour: int.tryParse(wParts[0]) ?? 7,
        minute: int.tryParse(wParts.length > 1 ? wParts[1] : '0') ?? 0,
      ),
      sleepTime: TimeOfDay(
        hour: int.tryParse(sParts[0]) ?? 22,
        minute: int.tryParse(sParts.length > 1 ? sParts[1] : '0') ?? 0,
      ),
      intervalMin: _userData.reminderIntervalMin,
      enabled: _userData.reminders,
      soundEnabled: _userData.sound,
      vibrationEnabled: _userData.vibration,
    );
  }

  List<double> getBarData(String period) {
    if (period == 'day') {
      List<double> data = List.filled(7, 0.0);
      final today = DateTime.now().toIso8601String().split('T')[0];
      for (var l in _logs.where((e) => e.date == today)) {
        try {
          final h = int.parse(l.time.split(':')[0]);
          if (h >= 8 && h < 10) {
            data[0] += l.ml;
          } else if (h >= 10 && h < 12) {
            data[1] += l.ml;
          } else if (h >= 12 && h < 14) {
            data[2] += l.ml;
          } else if (h >= 14 && h < 16) {
            data[3] += l.ml;
          } else if (h >= 16 && h < 18) {
            data[4] += l.ml;
          } else if (h >= 18 && h < 20) {
            data[5] += l.ml;
          } else if (h >= 20) {
            data[6] += l.ml;
          }
        } catch (_) {}
      }
      return data;
    } else if (period == 'week') {
      List<double> data = List.filled(7, 0.0);
      final now = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final d = now.subtract(Duration(days: 6 - i)).toIso8601String().split('T')[0];
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

  Map<String, int> get drinkTypeBreakdown {
    final today = DateTime.now().toIso8601String().split('T')[0];
    Map<String, int> breakdown = {
      'Water': 0,
      'Tea / Coffee': 0,
      'Juice': 0,
      'Sports drinks': 0,
    };
    for (var l in _logs.where((e) => e.date == today)) {
      if (breakdown.containsKey(l.label)) {
        breakdown[l.label] = breakdown[l.label]! + l.ml;
      } else {
        breakdown['Water'] = breakdown['Water']! + l.ml; // Fallback
      }
    }
    return breakdown;
  }

  void updateReminderInterval(int mins) {
    _userData.reminderIntervalMin = mins;
    _updateReminders();
    notifyListeners();
  }

  List<TimeOfDay> get generatedReminders {
    if (_userData.wakeTime.isEmpty || _userData.sleepTime.isEmpty) return [];
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
      if (sleep.isBefore(wake)) {
        sleep = sleep.add(const Duration(days: 1));
      }

      List<TimeOfDay> res = [];
      DateTime current = wake;
      while (current.isBefore(sleep) && res.length < 30) {
        res.add(TimeOfDay(hour: current.hour, minute: current.minute));
        current = current.add(Duration(minutes: _userData.reminderIntervalMin));
      }
      return res;
    } catch (e) {
      return [];
    }
  }

  void drinkWater(int ml, {String label = 'Water', String icon = '💧'}) {
    _userData.drunk = (_userData.drunk + ml).clamp(0, _userData.goal);
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
      _userData.drunk = (_userData.drunk - removed.ml).clamp(0, _userData.goal);
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
    _saveToPrefs();
    notifyListeners();
  }

  void updateWeight(int weight) {
    _userData.weight = weight;
    _userData.goal = weight * 35; // Default formula: 35ml per kg of body weight
    _saveToPrefs();
    notifyListeners();
  }

  void updateHeight(int height) {
    _userData.height = height;
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
    _saveToPrefs();
    notifyListeners();
  }

  void updateWakeTime(String time) {
    _userData.wakeTime = time;
    _updateReminders();
    _saveToPrefs();
    notifyListeners();
  }

  void updateSleepTime(String time) {
    _userData.sleepTime = time;
    _updateReminders();
    _saveToPrefs();
    notifyListeners();
  }

  void updateGoal(int goal) {
    _userData.goal = goal;
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
}
