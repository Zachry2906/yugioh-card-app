import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EnhancedCurrencyService {
  static const String _exchangeRateKey = 'exchange_rates';
  static const String _lastUpdateKey = 'exchange_rate_last_update';
  static const String _defaultCurrencyKey = 'default_currency';
  
  // Default exchange rates
  static const Map<String, double> _defaultRates = {
    'USD': 1.0,
    'IDR': 15500.0,
    'JPY': 150.0,
  };

  // Get all exchange rates
  static Future<Map<String, double>> getAllExchangeRates() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // If rates are cached and less than 24 hours old, use cached rates
    if (prefs.containsKey(_exchangeRateKey) && 
        now - lastUpdate < 24 * 60 * 60 * 1000) {
      final ratesJson = prefs.getString(_exchangeRateKey);
      if (ratesJson != null) {
        final Map<String, dynamic> decoded = json.decode(ratesJson);
        return decoded.map((key, value) => MapEntry(key, value.toDouble()));
      }
    }
    
    // Otherwise fetch new rates from API
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = <String, double>{
          'USD': 1.0,
          'IDR': data['rates']['IDR']?.toDouble() ?? _defaultRates['IDR']!,
          'JPY': data['rates']['JPY']?.toDouble() ?? _defaultRates['JPY']!,
        };
        
        // Cache the rates
        await prefs.setString(_exchangeRateKey, json.encode(rates));
        await prefs.setInt(_lastUpdateKey, now);
        
        return rates;
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
    }
    
    // Return cached rates or default rates
    final ratesJson = prefs.getString(_exchangeRateKey);
    if (ratesJson != null) {
      final Map<String, dynamic> decoded = json.decode(ratesJson);
      return decoded.map((key, value) => MapEntry(key, value.toDouble()));
    }
    
    return _defaultRates;
  }

  // Convert between currencies
  static Future<double> convertCurrency(double amount, String from, String to) async {
    if (from == to) return amount;
    
    final rates = await getAllExchangeRates();
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    
    // Convert to USD first, then to target currency
    final usdAmount = amount / fromRate;
    return usdAmount * toRate;
  }

  // Format currency with proper symbol
  static String formatCurrency(double amount, String currency) {
    switch (currency) {
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'IDR':
        final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},'
        );
        return 'Rp $formatted';
      case 'JPY':
        return '¥${amount.toStringAsFixed(0)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }

  // Get default currency from SharedPreferences
  static Future<String> getDefaultCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultCurrencyKey) ?? 'IDR';
  }

  // Set default currency
  static Future<void> setDefaultCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultCurrencyKey, currency);
  }

  // Get currency symbol
  static String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'IDR':
        return 'Rp';
      case 'JPY':
        return '¥';
      default:
        return currency;
    }
  }
}
