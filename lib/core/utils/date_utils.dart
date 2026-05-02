import 'package:intl/intl.dart';

class AppDateUtils {
  // Format: "Wednesday, 30 April 2025"
  static String formatDateFull(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy').format(date);
  }

  // Format: "30-Apr-2025"
  static String formatDateShort(DateTime date) {
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  // Format: "02:30 PM"
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  // Format: "30-Apr 02:30 PM"
  static String formatDateTimeShort(DateTime date) {
    return DateFormat('dd-MMM hh:mm a').format(date);
  }

  // Get relative time: "2 hours ago", "Yesterday", etc.
  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
  }

  // Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Get count of completed jobs today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
}
