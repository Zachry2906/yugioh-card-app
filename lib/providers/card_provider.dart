import 'package:flutter/material.dart';
import '../models/yugioh_card.dart';
import '../services/api_service.dart';

class CardProvider with ChangeNotifier {
  List<YugiohCard> _cards = [];
  List<YugiohCard> _searchResults = [];
  bool _isLoading = false;
  String _error = '';
  int _currentPage = 0;
  bool _hasMore = true;

  List<YugiohCard> get cards => _cards;
  List<YugiohCard> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadCards({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 0;
      _cards.clear();
      _hasMore = true;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newCards = await ApiService.getAllCards(
        limit: 20,
        offset: _currentPage * 20,
      );

      if (newCards.isEmpty) {
        _hasMore = false;
      } else {
        _cards.addAll(newCards);
        _currentPage++;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchCards(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _searchResults = await ApiService.searchCards(query);
    } catch (e) {
      _error = e.toString();
      _searchResults.clear();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCardsByType(String type) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _searchResults = await ApiService.getCardsByType(type);
    } catch (e) {
      _error = e.toString();
      _searchResults.clear();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults.clear();
    notifyListeners();
  }
}