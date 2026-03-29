import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_data.dart';
import '../models/drink_log.dart';

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
  int get remaining => _userData.goal - _userData.drunk;

  void drinkWater(int ml, {String label = 'Water', String icon = '💧'}) {
    _userData.drunk = (_userData.drunk + ml).clamp(0, _userData.goal);
    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _logs.insert(0, DrinkLog(time: timeStr, icon: icon, label: label, ml: ml));
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
    notifyListeners();
  }

  void updateGender(String gender) {
    _userData.gender = gender;
    notifyListeners();
  }

  void updateWeight(int weight) {
    _userData.weight = weight;
    _userData.goal = weight * 35; // Default formula: 35ml per kg of body weight
    notifyListeners();
  }

  void updateHeight(int height) {
    _userData.height = height;
    notifyListeners();
  }

  void updateAge(int age) {
    _userData.age = age;
    notifyListeners();
  }

  void updateActivity(String activity) {
    _userData.activity = activity;
    notifyListeners();
  }

  void updateWakeTime(String time) {
    _userData.wakeTime = time;
    notifyListeners();
  }

  void updateSleepTime(String time) {
    _userData.sleepTime = time;
    notifyListeners();
  }

  void updateGoal(int goal) {
    _userData.goal = goal;
    notifyListeners();
  }

  void toggleReminders(bool val) {
    _userData.reminders = val;
    notifyListeners();
  }

  void toggleSound(bool val) {
    _userData.sound = val;
    notifyListeners();
  }

  void toggleVibration(bool val) {
    _userData.vibration = val;
    notifyListeners();
  }

  void toggleDarkMode(bool val) {
    _userData.darkMode = val;
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
