import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _locationKey = 'user_location';
  static const String _countryKey = 'user_country';
  static const String _timezoneKey = 'user_timezone';

  // Get user's current location
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get country from coordinates
  static Future<String?> getCountryFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        return placemarks.first.country;
      }
    } catch (e) {
      print('Error getting country: $e');
    }
    return null;
  }

  // Determine timezone based on country
  static String getTimezoneFromCountry(String? country) {
    if (country == null) return 'WIB';
    
    switch (country.toLowerCase()) {
      case 'indonesia':
        return 'WIB'; // Default to WIB for Indonesia
      case 'japan':
        return 'JST';
      case 'united kingdom':
      case 'england':
        return 'GMT';
      default:
        return 'WIB';
    }
  }

  // Determine default currency based on country
  static String getDefaultCurrencyFromCountry(String? country) {
    if (country == null) return 'IDR';
    
    switch (country.toLowerCase()) {
      case 'indonesia':
        return 'IDR';
      case 'japan':
        return 'JPY';
      case 'united states':
      case 'united kingdom':
      default:
        return 'USD';
    }
  }

  // Save location data to SharedPreferences
  static Future<void> saveLocationData(Position position, String? country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, '${position.latitude},${position.longitude}');
    if (country != null) {
      await prefs.setString(_countryKey, country);
      await prefs.setString(_timezoneKey, getTimezoneFromCountry(country));
    }
  }

  // Get saved location data
  static Future<Map<String, String?>> getSavedLocationData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'location': prefs.getString(_locationKey),
      'country': prefs.getString(_countryKey),
      'timezone': prefs.getString(_timezoneKey),
    };
  }

  // Initialize location-based settings
  static Future<Map<String, String>> initializeLocationSettings() async {
    final position = await getCurrentLocation();
    String country = 'Indonesia'; // Default
    String timezone = 'WIB';
    String currency = 'IDR';

    if (position != null) {
      final detectedCountry = await getCountryFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      if (detectedCountry != null) {
        country = detectedCountry;
        timezone = getTimezoneFromCountry(country);
        currency = getDefaultCurrencyFromCountry(country);
        
        await saveLocationData(position, country);
      }
    }

    return {
      'country': country,
      'timezone': timezone,
      'currency': currency,
    };
  }
}
