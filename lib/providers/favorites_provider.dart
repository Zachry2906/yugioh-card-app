import 'package:flutter/material.dart';
import '../models/yugioh_card.dart';
import '../services/database_helper.dart';

class FavoritesProvider with ChangeNotifier {
  List<YugiohCard> _favorites = [];
  bool _isLoading = false;
  List<YugiohCard> _memoryFavorites = []; // Fallback untuk jika database tidak tersedia

  List<YugiohCard> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (DatabaseHelper.instance.isAvailable) {
        _favorites = await DatabaseHelper.instance.getFavorites();
      } else {
        // Fallback ke memory storage
        _favorites = List.from(_memoryFavorites);
      }
    } catch (e) {
      print('Error loading favorites: $e');
      _favorites = List.from(_memoryFavorites);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToFavorites(YugiohCard card) async {
    try {
      if (DatabaseHelper.instance.isAvailable) {
        final result = await DatabaseHelper.instance.addToFavorites(card);
        if (result != -1) {
          _favorites.add(card);
        }
      } else {
        // Fallback ke memory storage
        if (!_memoryFavorites.any((c) => c.id == card.id)) {
          _memoryFavorites.add(card);
          _favorites.add(card);
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  Future<void> removeFromFavorites(YugiohCard card) async {
    try {
      if (DatabaseHelper.instance.isAvailable) {
        await DatabaseHelper.instance.removeFromFavorites(card.id);
      } else {
        // Fallback ke memory storage
        _memoryFavorites.removeWhere((c) => c.id == card.id);
      }
      _favorites.removeWhere((c) => c.id == card.id);
      notifyListeners();
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  Future<bool> isFavorite(int cardId) async {
    try {
      if (DatabaseHelper.instance.isAvailable) {
        return await DatabaseHelper.instance.isFavorite(cardId);
      } else {
        return _memoryFavorites.any((card) => card.id == cardId);
      }
    } catch (e) {
      return _memoryFavorites.any((card) => card.id == cardId);
    }
  }

  bool isFavoriteSync(int cardId) {
    return _favorites.any((card) => card.id == cardId);
  }
}
