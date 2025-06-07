import 'package:flutter/material.dart';
import '../models/yugioh_card.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class FavoritesProvider extends ChangeNotifier {
  List<YugiohCard> _favorites = [];
  bool _isLoading = false;
  String _error = '';

  List<YugiohCard> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _favorites = await DatabaseHelper.instance.getFavoriteCards();
    } catch (e) {
      _error = 'Failed to load favorites: $e';
      print('Error loading favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToFavorites(YugiohCard card) async {
    try {
      await DatabaseHelper.instance.insertFavoriteCard(card);
      _favorites.insert(0, card); // Add to beginning of list
      notifyListeners();

      // Show notification
      await NotificationService.showFavoriteAddedNotification(card.name);
    } catch (e) {
      if (e.toString().contains('already in favorites')) {
        _error = 'Card is already in favorites';
      } else {
        _error = 'Failed to add to favorites: $e';
      }
      print('Error adding to favorites: $e');
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(YugiohCard card) async {
    try {
      await DatabaseHelper.instance.deleteFavoriteCard(card.id);
      _favorites.removeWhere((c) => c.id == card.id);
      notifyListeners();

      // Show notification
      await NotificationService.showFavoriteRemovedNotification(card.name);
    } catch (e) {
      _error = 'Failed to remove from favorites: $e';
      print('Error removing from favorites: $e');
      notifyListeners();
    }
  }

  Future<bool> isFavorite(int cardId) async {
    try {
      return await DatabaseHelper.instance.isFavoriteCard(cardId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  bool isFavoriteSync(int cardId) {
    return _favorites.any((card) => card.id == cardId);
  }

  Future<void> toggleFavorite(YugiohCard card) async {
    final isFav = await isFavorite(card.id);
    if (isFav) {
      await removeFromFavorites(card);
    } else {
      await addToFavorites(card);
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
