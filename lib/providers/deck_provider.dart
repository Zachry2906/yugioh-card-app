import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/yugioh_card.dart';
import '../services/database_helper.dart';

class DeckProvider with ChangeNotifier {
  List<Deck> _decks = [];
  bool _isLoading = false;
  List<Deck> _memoryDecks = []; // Fallback untuk jika database tidak tersedia
  Map<int, List<YugiohCard>> _memoryDeckCards = {}; // Fallback untuk kartu deck

  List<Deck> get decks => _decks;
  bool get isLoading => _isLoading;

  Future<void> loadDecks() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (DatabaseHelper.instance.isAvailable) {
        _decks = await DatabaseHelper.instance.getDecks();
      } else {
        _decks = List.from(_memoryDecks);
      }
    } catch (e) {
      print('Error loading decks: $e');
      _decks = List.from(_memoryDecks);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createDeck(String name, String description) async {
    try {
      final deck = Deck(
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );

      if (DatabaseHelper.instance.isAvailable) {
        final id = await DatabaseHelper.instance.createDeck(deck);
        if (id != -1) {
          final newDeck = deck.copyWith(id: id);
          _decks.insert(0, newDeck);
        }
      } else {
        // Fallback ke memory storage
        final id = DateTime.now().millisecondsSinceEpoch; // Generate unique ID
        final newDeck = deck.copyWith(id: id);
        _memoryDecks.insert(0, newDeck);
        _decks.insert(0, newDeck);
        _memoryDeckCards[id] = [];
      }
      notifyListeners();
    } catch (e) {
      print('Error creating deck: $e');
    }
  }

  Future<void> updateDeck(Deck deck) async {
    try {
      if (DatabaseHelper.instance.isAvailable) {
        await DatabaseHelper.instance.updateDeck(deck);
      } else {
        // Update in memory
        final index = _memoryDecks.indexWhere((d) => d.id == deck.id);
        if (index != -1) {
          _memoryDecks[index] = deck;
        }
      }

      final index = _decks.indexWhere((d) => d.id == deck.id);
      if (index != -1) {
        _decks[index] = deck;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating deck: $e');
    }
  }

  Future<void> deleteDeck(int deckId) async {
    try {
      if (DatabaseHelper.instance.isAvailable) {
        await DatabaseHelper.instance.deleteDeck(deckId);
      } else {
        _memoryDecks.removeWhere((deck) => deck.id == deckId);
        _memoryDeckCards.remove(deckId);
      }

      _decks.removeWhere((deck) => deck.id == deckId);
      notifyListeners();
    } catch (e) {
      print('Error deleting deck: $e');
    }
  }

  Future<List<YugiohCard>> getDeckCards(int deckId) async {
    try {
      if (DatabaseHelper.instance.isAvailable) {
        return await DatabaseHelper.instance.getDeckCards(deckId);
      } else {
        return _memoryDeckCards[deckId] ?? [];
      }
    } catch (e) {
      print('Error getting deck cards: $e');
      return _memoryDeckCards[deckId] ?? [];
    }
  }

  Future<void> addCardToDeck(int deckId, YugiohCard card) async {
    try {
      if (DatabaseHelper.instance.isAvailable) {
        await DatabaseHelper.instance.addCardToDeck(deckId, card);
      } else {
        if (_memoryDeckCards[deckId] == null) {
          _memoryDeckCards[deckId] = [];
        }
        _memoryDeckCards[deckId]!.add(card);
      }
      notifyListeners();
    } catch (e) {
      print('Error adding card to deck: $e');
    }
  }

  Future<void> removeCardFromDeck(int deckId, int cardId) async {
    try {
      if (DatabaseHelper.instance.isAvailable) {
        await DatabaseHelper.instance.removeCardFromDeck(deckId, cardId);
      } else {
        _memoryDeckCards[deckId]?.removeWhere((card) => card.id == cardId);
      }
      notifyListeners();
    } catch (e) {
      print('Error removing card from deck: $e');
    }
  }
}
