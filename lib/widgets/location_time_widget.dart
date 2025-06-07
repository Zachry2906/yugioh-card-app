import 'package:flutter/material.dart';
import '../services/time_service.dart';
import '../services/location_service.dart';

class LocationTimeWidget extends StatefulWidget {
  @override
  _LocationTimeWidgetState createState() => _LocationTimeWidgetState();
}

class _LocationTimeWidgetState extends State<LocationTimeWidget> {
  Map<String, String> _currentTimes = {};
  String _userTimezone = 'WIB';
  String _userCountry = 'Indonesia';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _startClock();
  }

  @override
  void dispose() {
    TimeService.stopClock();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final locationData = await LocationService.getSavedLocationData();
    if (mounted) {
      setState(() {
        _userCountry = locationData['country'] ?? 'Indonesia';
        _userTimezone = locationData['timezone'] ?? 'WIB';
      });
    }
  }

  void _startClock() {
    TimeService.startClock((times) {
      if (mounted) {
        setState(() {
          _currentTimes = times;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.purple[800], size: 20),
                SizedBox(width: 8),
                Text(
                  'Location: $_userCountry',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Trading Card Market Times',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            _buildTimeRow('WIB', 'Jakarta, Indonesia', _userTimezone == 'WIB'),
            _buildTimeRow('WITA', 'Makassar, Indonesia', _userTimezone == 'WITA'),
            _buildTimeRow('WIT', 'Jayapura, Indonesia', _userTimezone == 'WIT'),
            _buildTimeRow('JST', 'Tokyo, Japan', _userTimezone == 'JST'),
            _buildTimeRow('GMT', 'London, UK', _userTimezone == 'GMT'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String timezone, String location, bool isUserTimezone) {
    final time = _currentTimes[timezone] ?? '--:--:--';
    final marketStatus = TimeService.getMarketStatus(timezone);
    final isOpen = marketStatus == 'Market Open';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      margin: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isUserTimezone ? Colors.purple[50] : null,
        borderRadius: BorderRadius.circular(8),
        border: isUserTimezone ? Border.all(color: Colors.purple[300]!) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              timezone,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUserTimezone ? Colors.purple[800] : Colors.black,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              location,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: isUserTimezone ? Colors.purple[800] : Colors.black,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isOpen ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isOpen ? 'Open' : 'Closed',
              style: TextStyle(
                fontSize: 10,
                color: isOpen ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
