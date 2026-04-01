import 'package:flutter/material.dart';

class TimeUtils {
  /// Formats a time string (HH:mm) into either 12h or 24h format.
  /// [is24Hour] defaults to false if null.
  static String formatString(String timeStr, bool? is24Hour) {
    if (timeStr.isEmpty) return '--:--';
    final parts = timeStr.split(':');
    if (parts.length != 2) return timeStr;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return formatTimeOfDay(TimeOfDay(hour: hour, minute: minute), is24Hour);
  }

  /// Formats a [TimeOfDay] into either 12h or 24h format.
  static String formatTimeOfDay(TimeOfDay time, bool? is24Hour) {
    final use24h = is24Hour ?? false;

    if (use24h) {
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else {
      final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final m = time.minute.toString().padLeft(2, '0');
      final period = time.hour < 12 ? 'AM' : 'PM';
      return '$h:$m $period';
    }
  }
}
