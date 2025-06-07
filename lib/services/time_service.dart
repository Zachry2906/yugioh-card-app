import 'dart:async';

class TimeService {
  static Timer? _timer;
  static Function(Map<String, String>)? _onTimeUpdate;

  // Start real-time clock updates
  static void startClock(Function(Map<String, String>) onUpdate) {
    _onTimeUpdate = onUpdate;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _onTimeUpdate?.call(getCurrentTimes());
    });
  }

  // Stop clock updates
  static void stopClock() {
    _timer?.cancel();
    _timer = null;
    _onTimeUpdate = null;
  }

  // Get current times for all timezones
  static Map<String, String> getCurrentTimes() {
    final now = DateTime.now().toUtc();
    
    return {
      'WIB': _formatTime(now.add(Duration(hours: 7))), // UTC+7
      'WITA': _formatTime(now.add(Duration(hours: 8))), // UTC+8
      'WIT': _formatTime(now.add(Duration(hours: 9))), // UTC+9
      'JST': _formatTime(now.add(Duration(hours: 9))), // UTC+9 (Japan)
      'GMT': _formatTime(now), // UTC+0 (London)
    };
  }

  // Format time to readable string
  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }

  // Get timezone label
  static String getTimezoneLabel(String timezone) {
    switch (timezone) {
      case 'WIB':
        return 'WIB (Jakarta)';
      case 'WITA':
        return 'WITA (Makassar)';
      case 'WIT':
        return 'WIT (Jayapura)';
      case 'JST':
        return 'JST (Tokyo)';
      case 'GMT':
        return 'GMT (London)';
      default:
        return timezone;
    }
  }

  // Get market opening status based on timezone
  static String getMarketStatus(String timezone) {
    final times = getCurrentTimes();
    final currentTime = times[timezone] ?? '00:00:00';
    final hour = int.parse(currentTime.split(':')[0]);

    // Simulate trading card market hours
    if (hour >= 9 && hour < 21) {
      return 'Market Open';
    } else {
      return 'Market Closed';
    }
  }
}
