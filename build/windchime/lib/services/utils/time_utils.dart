class TimeUtils {
  // int seconds to timer ticks (100ms per tick)
  static int secondsToTicks(int seconds) {
    return seconds * 10;
  }

  // ticks to seconds
  static int ticksToSeconds(int ticks) {
    return ticks ~/ 10;
  }

  // time duration string (ticks)
  static String durationString(int ticks) {
    final int seconds = ticksToSeconds(ticks);
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // time duration string (seconds)
  static String durationStringSeconds(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // time duration string (ticks) with hours
  static String durationStringWithHours(int ticks) {
    final int seconds = ticksToSeconds(ticks);
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
