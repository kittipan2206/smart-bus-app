class UnitUtils {
  static String formatDuration({duration, bool passed = false}) {
    String timeString = '';
    const timeThreshold = 2.0;
    // convert time to string hours or minutes
    // return duration.toString();
    if (passed) {
      return 'Passed';
    } else if (duration < 30) {
      timeString = 'Almost there';
    } else if (duration < 60) {
      timeString = '1 min';
    } else if (duration < 3600) {
      final time = duration / 60;
      timeString =
          '${(time).toStringAsFixed(0)} - ${(time + timeThreshold).toStringAsFixed(0)} min';
    } else {
      timeString =
          '${(duration / 3600).toStringAsFixed(0)} hours ${(duration % 3600 / 60).toStringAsFixed(0)} min';
    }

    return timeString;
  }
}
