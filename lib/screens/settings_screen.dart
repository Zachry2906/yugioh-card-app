import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/enhanced_currency_service.dart';
import '../widgets/location_time_widget.dart';
import '../widgets/currency_converter_widget.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCurrency = 'IDR';
  String _userCountry = 'Indonesia';
  bool _isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final currency = await EnhancedCurrencyService.getDefaultCurrency();
    final locationData = await LocationService.getSavedLocationData();

    if (mounted) {
      setState(() {
        _selectedCurrency = currency;
        _userCountry = locationData['country'] ?? 'Indonesia';
        _isLocationEnabled = locationData['location'] != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Location & Time Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location & Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Current Location'),
                    subtitle: Text(_userCountry),
                    trailing: Switch(
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
                  ),
                  if (_isLocationEnabled)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: LocationTimeWidget(),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Currency Converter Section
          CurrencyConverterWidget(),

          SizedBox(height: 16),

          // Currency Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currency Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.attach_money),
                    title: Text('Default Currency'),
                    subtitle: Text('Used for card price display'),
                    trailing: DropdownButton<String>(
                      value: _selectedCurrency,
                      onChanged: (value) async {
                        if (value != null) {
                          await EnhancedCurrencyService.setDefaultCurrency(value);
                          setState(() {
                            _selectedCurrency = value;
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                        DropdownMenuItem(value: 'IDR', child: Text('IDR (Rp)')),
                        DropdownMenuItem(value: 'JPY', child: Text('JPY (¥)')),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Supported currencies: USD (United States), IDR (Indonesia), JPY (Japan)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // LBS Info Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location-Based Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildFeatureItem(
                    Icons.location_on,
                    'Auto Currency Detection',
                    'Automatically sets currency based on your location',
                  ),
                  _buildFeatureItem(
                    Icons.access_time,
                    'Market Hours',
                    'Shows trading card market hours across different timezones',
                  ),
                  _buildFeatureItem(
                    Icons.trending_up,
                    'Regional Pricing',
                    'Displays card prices in your local currency',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple[800], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enableLocation() async {
    try {
      final locationSettings = await LocationService.initializeLocationSettings();

      setState(() {
        _userCountry = locationSettings['country'] ?? 'Indonesia';
        _selectedCurrency = locationSettings['currency'] ?? 'IDR';
        _isLocationEnabled = true;
      });

      // Update default currency based on location
      await EnhancedCurrencyService.setDefaultCurrency(_selectedCurrency);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location detected: $_userCountry. Currency set to $_selectedCurrency'),
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
}
