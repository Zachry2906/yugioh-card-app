import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _exchangeRateKey = 'usd_to_idr_rate';
  static const String _lastUpdateKey = 'exchange_rate_last_update';

  static const double _defaultRate = 15500.0;

  static Future<double> getUsdToIdrRate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (prefs.containsKey(_exchangeRateKey) && 
        now - lastUpdate < 24 * 60 * 60 * 1000) {
      return prefs.getDouble(_exchangeRateKey) ?? _defaultRate;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      ).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['rates'] != null && data['rates']['IDR'] != null) {
          final rate = data['rates']['IDR'].toDouble();
          
          // Cache the rate
          await prefs.setDouble(_exchangeRateKey, rate);
          await prefs.setInt(_lastUpdateKey, now);
          
          return rate;
        }
      }

      return prefs.getDouble(_exchangeRateKey) ?? _defaultRate;
    } catch (e) {
      return prefs.getDouble(_exchangeRateKey) ?? _defaultRate;
    }
  }

  static Future<double> convertUsdToIdr(double usdAmount) async {
    final rate = await getUsdToIdrRate();
    return usdAmount * rate;
  }

  static String formatUsd(double? price) {
    if (price == null) return 'N/A';
    return '\$${price.toStringAsFixed(2)}';
  }

  static String formatIdr(double? price) {
    if (price == null) return 'N/A';

    final formatted = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
    
    return 'Rp $formatted';
  }
}
