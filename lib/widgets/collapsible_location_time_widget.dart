import 'package:flutter/material.dart';
import '../services/time_service.dart';
import '../services/location_service.dart';

class CollapsibleLocationTimeWidget extends StatefulWidget {
  @override
  _CollapsibleLocationTimeWidgetState createState() => _CollapsibleLocationTimeWidgetState();
}

class _CollapsibleLocationTimeWidgetState extends State<CollapsibleLocationTimeWidget> {
  Map<String, String> _currentTimes = {};
  String _userTimezone = 'WIB';
  String _userCountry = 'Indonesia';
  bool _isExpanded = false;
  bool _isLocationEnabled = false;

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
        _isLocationEnabled = locationData['location'] != null;
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

  Future<void> _enableLocation() async {
    try {
      final locationSettings = await LocationService.initializeLocationSettings();
      
      setState(() {
        _userCountry = locationSettings['country'] ?? 'Indonesia';
        _userTimezone = locationSettings['timezone'] ?? 'WIB';
        _isLocationEnabled = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location detected: $_userCountry'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location. Please check permissions.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Header
          ListTile(
            leading: Icon(Icons.location_on, color: Colors.purple[800]),
            title: Text(
              'Location & Time',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(_isLocationEnabled ? _userCountry : 'Location disabled'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _isLocationEnabled,
                  onChanged: (value) async {
                    if (value) {
                      await _enableLocation();
                    } else {
                      setState(() {
                        _isLocationEnabled = false;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Expandable content
          if (_isExpanded && _isLocationEnabled)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  SizedBox(height: 8),
                  Text(
                    'Trading Card Market Times',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildTimeRow('WIB', 'Jakarta, Indonesia', _userTimezone == 'WIB'),
                  _buildTimeRow('WITA', 'Makassar, Indonesia', _userTimezone == 'WITA'),
                  _buildTimeRow('WIT', 'Jayapura, Indonesia', _userTimezone == 'WIT'),
                  _buildTimeRow('JST', 'Tokyo, Japan', _userTimezone == 'JST'),
                  _buildTimeRow('GMT', 'London, UK', _userTimezone == 'GMT'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String timezone, String location, bool isUserTimezone) {
    final time = _currentTimes[timezone] ?? '--:--:--';
    final marketStatus = TimeService.getMarketStatus(timezone);
    final isOpen = marketStatus == 'Market Open';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
                fontSize: 12,
                color: isUserTimezone ? Colors.purple[800] : Colors.black,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              location,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isUserTimezone ? Colors.purple[800] : Colors.black,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isOpen ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isOpen ? 'Open' : 'Closed',
              style: TextStyle(
                fontSize: 9,
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
