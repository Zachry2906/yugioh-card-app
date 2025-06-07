import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tugasakhirpraktikum/models/yugioh_card.dart';

class ApiService {
  static String baseUrl = 'https://db.ygoprodeck.com/api/v7';

  static Future<List<YugiohCard>> getAllCards({int limit = 20, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cardinfo.php?num=$limit&offset=$offset'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsJson = data['data'];
        return cardsJson.map((json) => YugiohCard.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cards: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cards: $e');
    }
  }

  static Future<List<YugiohCard>> searchCards(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cardinfo.php?fname=$query'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsJson = data['data'];
        return cardsJson.map((json) => YugiohCard.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  static Future<List<YugiohCard>> getCardsByType(String type) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cardinfo.php?type=$type'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsJson = data['data'];
        return cardsJson.map((json) => YugiohCard.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Get cards by type error: $e');
      return [];
    }
  }
}
