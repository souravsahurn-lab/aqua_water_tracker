class UserData {
  String name;
  int age;
  int weight;
  int height;
  String activity;
  String wakeTime;
  String sleepTime;
  int goal;
  int drunk;
  bool reminders;
  bool sound;
  bool vibration;
  bool darkMode;
  String gender;
  int streak;
  String lastActiveDate;
  int reminderIntervalMin;
  String notificationSound;
  bool smartReminders;
  bool customGoal;
  List<String> customReminderTimes; // HH:mm strings for manual reminders

  UserData({
    this.name = '',
    this.age = 25,
    this.weight = 70,
    this.height = 170,
    this.activity = 'moderate',
    this.wakeTime = '07:00',
    this.sleepTime = '22:00',
    this.goal = 2450,
    this.drunk = 0,
    this.reminders = true,
    this.sound = true,
    this.vibration = true,
    this.darkMode = false,
    this.gender = 'male',
    this.streak = 0,
    String? lastActiveDate,
    this.reminderIntervalMin = 120,
    this.notificationSound = 'floraphonic_water_droplet_4_165639_mp3_mpeg',
    this.smartReminders = true,
    this.customGoal = false,
    List<String>? customReminderTimes,
  })  : lastActiveDate = lastActiveDate ?? DateTime.now().toIso8601String().split('T')[0],
        customReminderTimes = customReminderTimes ?? [];

  /// Calculates recommended daily water intake in ml
  /// Formula:
  ///   base = weight(kg) × 30ml
  ///   activity multiplier: sedentary ×1.0, light ×1.15, moderate ×1.30, active ×1.45, very active ×1.60
  ///   height adjustment: +100ml for every 10cm above 170cm, -50ml for every 10cm below
  ///   gender: males +200ml
  ///   Result rounded to nearest 50ml
  static int calculateGoal({
    required int weight,
    required int height,
    required String activity,
    required String gender,
  }) {
    double base = weight * 30.0;

    // Activity multiplier
    double multiplier;
    switch (activity.toLowerCase()) {
      case 'sedentary':
        multiplier = 1.0;
        break;
      case 'light':
        multiplier = 1.15;
        break;
      case 'moderate':
        multiplier = 1.30;
        break;
      case 'active':
        multiplier = 1.45;
        break;
      case 'very active':
        multiplier = 1.60;
        break;
      default:
        multiplier = 1.30;
    }

    double result = base * multiplier;

    // Height adjustment
    int heightDiff = height - 170;
    if (heightDiff > 0) {
      result += (heightDiff / 10) * 100;
    } else if (heightDiff < 0) {
      result += (heightDiff / 10) * 50; // subtract 50ml per 10cm below 170
    }

    // Gender adjustment
    if (gender.toLowerCase() == 'male') {
      result += 200;
    }

    // Round to nearest 50ml, minimum 1000ml
    int rounded = ((result / 50).round() * 50).clamp(1000, 6000);
    return rounded;
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 25,
      weight: json['weight'] as int? ?? 70,
      height: json['height'] as int? ?? 170,
      activity: json['activity'] as String? ?? 'moderate',
      wakeTime: json['wakeTime'] as String? ?? '07:00',
      sleepTime: json['sleepTime'] as String? ?? '22:00',
      goal: json['goal'] as int? ?? 2450,
      drunk: json['drunk'] as int? ?? 0,
      reminders: json['reminders'] as bool? ?? true,
      sound: json['sound'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
      darkMode: json['darkMode'] as bool? ?? false,
      gender: json['gender'] as String? ?? 'male',
      streak: json['streak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] as String?,
      reminderIntervalMin: json['reminderIntervalMin'] as int? ?? 120,
      notificationSound: json['notificationSound'] as String? ?? 'floraphonic_water_droplet_4_165639_mp3_mpeg',
      smartReminders: json['smartReminders'] as bool? ?? true,
      customGoal: json['customGoal'] as bool? ?? false,
      customReminderTimes: (json['customReminderTimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'activity': activity,
      'wakeTime': wakeTime,
      'sleepTime': sleepTime,
      'goal': goal,
      'drunk': drunk,
      'reminders': reminders,
      'sound': sound,
      'vibration': vibration,
      'darkMode': darkMode,
      'gender': gender,
      'streak': streak,
      'lastActiveDate': lastActiveDate,
      'reminderIntervalMin': reminderIntervalMin,
      'notificationSound': notificationSound,
      'smartReminders': smartReminders,
      'customGoal': customGoal,
      'customReminderTimes': customReminderTimes,
    };
  }
}
