class DrinkLog {
  final String time;
  final String icon;
  final String label;
  final int ml;

  DrinkLog({
    required this.time,
    required this.icon,
    required this.label,
    required this.ml,
  });

  factory DrinkLog.fromJson(Map<String, dynamic> json) {
    return DrinkLog(
      time: json['time'] as String,
      icon: json['icon'] as String,
      label: json['label'] as String,
      ml: json['ml'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'icon': icon,
      'label': label,
      'ml': ml,
    };
  }
}
