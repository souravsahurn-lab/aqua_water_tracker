class DrinkLog {
  final String date;
  final String time;
  final String icon;
  final String label;
  final int ml;

  DrinkLog({
    required this.date,
    required this.time,
    required this.icon,
    required this.label,
    required this.ml,
  });

  factory DrinkLog.fromJson(Map<String, dynamic> json) {
    return DrinkLog(
      date: json['date'] as String? ?? DateTime.now().toIso8601String().split('T')[0],
      time: json['time'] as String,
      icon: json['icon'] as String,
      label: json['label'] as String,
      ml: json['ml'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'icon': icon,
      'label': label,
      'ml': ml,
    };
  }
}
