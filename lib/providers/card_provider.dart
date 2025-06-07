import 'package:flutter/material.dart';
import '../models/yugioh_card.dart';
import '../services/api_service.dart';

class CardProvider extends ChangeNotifier {
  List<YugiohCard> _cards = [];
  List<YugiohCard> _searchResults = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _error = '';
  int _currentOffset = 0;
  static const int _limit = 20;

  List<YugiohCard> get cards => _cards;
  List<YugiohCard> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get error => _error;

  Future<void> loadCards({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _cards.clear();
      _currentOffset = 0;
      _hasMore = true;
      _error = '';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final newCards = await ApiService.getAllCards(
        limit: _limit,
        offset: _currentOffset,
      );

      if (newCards.isEmpty) {
        _hasMore = false;
      } else {
        _cards.addAll(newCards);
        _currentOffset += _limit;
      }

      _error = '';
    } catch (e) {
      _error = e.toString();
      print('Error loading cards: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchCards(String query) async {
    if (query.trim().isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _searchResults = await ApiService.searchCards(query);
      _error = '';
    } catch (e) {
      _error = e.toString();
      _searchResults.clear();
      print('Error searching cards: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCardsByType(String type) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _cards = await ApiService.getCardsByType(type);
      _currentOffset = _cards.length;
      _hasMore = false; // Type filtering doesn't support pagination
      _error = '';
    } catch (e) {
      _error = e.toString();
      print('Error loading cards by type: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults.clear();
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
