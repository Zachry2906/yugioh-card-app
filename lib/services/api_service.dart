import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/yugioh_card.dart';

class ApiService {
  static const String baseUrl = 'https://db.ygoprodeck.com/api/v7';

  static Future<List<YugiohCard>> getAllCards({int limit = 20, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cardinfo.php?num=$limit&offset=$offset'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsJson = data['data'];
        return cardsJson.map((json) => YugiohCard.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cards');
      }
    } catch (e) {
      throw Exception('Error fetching cards: $e');
    }
  }

  static Future<List<YugiohCard>> searchCards(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cardinfo.php?fname=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsJson = data['data'];
        return cardsJson.map((json) => YugiohCard.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<YugiohCard>> getCardsByType(String type) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cardinfo.php?type=$type'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsJson = data['data'];
        return cardsJson.map((json) => YugiohCard.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<YugiohCard?> getCardById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cardinfo.php?id=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsJson = data['data'];
        if (cardsJson.isNotEmpty) {
          return YugiohCard.fromJson(cardsJson.first);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}