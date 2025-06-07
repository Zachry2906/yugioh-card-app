import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/yugioh_card.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class DeckProvider extends ChangeNotifier {
  List<Deck> _decks = [];
  bool _isLoading = false;
  String _error = '';

  List<Deck> get decks => _decks;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadDecks() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _decks = await DatabaseHelper.instance.getDecks();
    } catch (e) {
      _error = 'Failed to load decks: $e';
      print('Error loading decks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDeck(String name, String description) async {
    try {
      final deck = Deck(
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );

      final id = await DatabaseHelper.instance.insertDeck(deck);
      deck.id = id;
      _decks.insert(0, deck); // Add to beginning of list
      notifyListeners();

      // Show notification
      await NotificationService.showDeckNotification(
        '🎴 New Deck Created!',
        'Deck "$name" has been created successfully',
      );
    } catch (e) {
      _error = 'Failed to create deck: $e';
      print('Error creating deck: $e');
      notifyListeners();
      rethrow; // Re-throw to handle in UI
    }
  }

  Future<void> deleteDeck(int deckId) async {
    try {
      final deck = _decks.firstWhere((d) => d.id == deckId);
      await DatabaseHelper.instance.deleteDeck(deckId);
      _decks.removeWhere((d) => d.id == deckId);
      notifyListeners();

      // Show notification
      await NotificationService.showDeckNotification(
        '🗑️ Deck Deleted',
        'Deck "${deck.name}" has been deleted',
      );
    } catch (e) {
      _error = 'Failed to delete deck: $e';
      print('Error deleting deck: $e');
      notifyListeners();
      rethrow; // Re-throw to handle in UI
    }
  }

  Future<void> addCardToDeck(int deckId, YugiohCard card) async {
    try {
      // First, make sure the card is in favorites (our card storage)
      final isFavorite = await DatabaseHelper.instance.isFavoriteCard(card.id);
      if (!isFavorite) {
        await DatabaseHelper.instance.insertFavoriteCard(card);
      }

      await DatabaseHelper.instance.addCardToDeck(deckId, card.id);

      // Update deck card count
      final deckIndex = _decks.indexWhere((d) => d.id == deckId);
      if (deckIndex != -1) {
        _decks[deckIndex].cardCount = await DatabaseHelper.instance.getDeckCardCount(deckId);
        notifyListeners();
      }

      final deck = _decks.firstWhere((d) => d.id == deckId);

      // Show notification
      await NotificationService.showDeckNotification(
        '➕ Card Added to Deck!',
        '${card.name} has been added to "${deck.name}"',
      );
    } catch (e) {
      _error = 'Failed to add card to deck: $e';
      print('Error adding card to deck: $e');
      notifyListeners();
      rethrow; // Re-throw to handle in UI
    }
  }

  Future<void> removeCardFromDeck(int deckId, int cardId) async {
    try {
      await DatabaseHelper.instance.removeCardFromDeck(deckId, cardId);

      // Update deck card count
      final deckIndex = _decks.indexWhere((d) => d.id == deckId);
      if (deckIndex != -1) {
        _decks[deckIndex].cardCount = await DatabaseHelper.instance.getDeckCardCount(deckId);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to remove card from deck: $e';
      print('Error removing card from deck: $e');
      notifyListeners();
      rethrow; // Re-throw to handle in UI
    }
  }

  Future<List<YugiohCard>> getDeckCards(int deckId) async {
    try {
      return await DatabaseHelper.instance.getDeckCards(deckId);
    } catch (e) {
      _error = 'Failed to load deck cards: $e';
      print('Error loading deck cards: $e');
      notifyListeners();
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDeckCardsWithQuantity(int deckId) async {
    try {
      return await DatabaseHelper.instance.getDeckCardsWithQuantity(deckId);
    } catch (e) {
      _error = 'Failed to load deck cards with quantity: $e';
      print('Error loading deck cards with quantity: $e');
      notifyListeners();
      return [];
    }
  }

  Deck? getDeckById(int deckId) {
    try {
      return _decks.firstWhere((deck) => deck.id == deckId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
