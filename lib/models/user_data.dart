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
  });

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
    };
  }
}
