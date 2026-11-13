/// Date and time formatting helpers that do not depend on Flutter widgets.
abstract final class DateTimeUtils {
  /// Formats epoch milliseconds as `yyyy-MM-dd HH:mm:ss` in local time.
  static String formatEpochMillis(int epochMillis) =>
      formatDateTime(DateTime.fromMillisecondsSinceEpoch(epochMillis));

  static String formatDateTime(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)} '
        '${_two(local.hour)}:${_two(local.minute)}:${_two(local.second)}';
  }

  /// Formats a minute-of-day value (0..1439) as `HH:mm`.
  static String formatMinuteOfDay(int minuteOfDay) =>
      '${_two(minuteOfDay ~/ 60)}:${_two(minuteOfDay % 60)}';

  static String _two(int value) => value.toString().padLeft(2, '0');
}
