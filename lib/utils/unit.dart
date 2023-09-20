class UnitUtils {
  static String formatDuration(duration) {
    String timeString = '';
    // convert time to string hours or minutes
    if (duration < 60) {
      timeString = '$duration s';
    } else if (duration < 3600) {
      timeString = '${(duration / 60).toStringAsFixed(0)} min';
    } else {
      timeString = '${(duration / 3600).toStringAsFixed(0)} hours';
    }
    return timeString;
  }
}
