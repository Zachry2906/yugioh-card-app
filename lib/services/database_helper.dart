import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/yugioh_card.dart';
import '../models/deck.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yugioh_tcg.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        desc TEXT NOT NULL,
        race TEXT,
        attribute TEXT,
        level INTEGER,
        atk INTEGER,
        def INTEGER,
        card_images TEXT NOT NULL,
        card_prices TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create decks table
    await db.execute('''
      CREATE TABLE decks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create deck_cards table (junction table)
    await db.execute('''
      CREATE TABLE deck_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        deck_id INTEGER NOT NULL,
        card_id INTEGER NOT NULL,
        quantity INTEGER DEFAULT 1,
        added_at TEXT NOT NULL,
        FOREIGN KEY (deck_id) REFERENCES decks (id) ON DELETE CASCADE,
        UNIQUE(deck_id, card_id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_deck_cards_deck_id ON deck_cards(deck_id)');
    await db.execute('CREATE INDEX idx_deck_cards_card_id ON deck_cards(card_id)');
  }

  // Favorites methods
  Future<List<YugiohCard>> getFavoriteCards() async {
    final db = await instance.database;
    final result = await db.query('favorites', orderBy: 'created_at DESC');

    return result.map((json) => YugiohCard.fromDatabase(json)).toList();
  }

  Future<int> insertFavoriteCard(YugiohCard card) async {
    final db = await instance.database;

    // Check if already exists
    final existing = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [card.id],
    );

    if (existing.isNotEmpty) {
      throw Exception('Card already in favorites');
    }

    return await db.insert('favorites', card.toDatabase());
  }

  Future<int> deleteFavoriteCard(int cardId) async {
    final db = await instance.database;
    return await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  Future<bool> isFavoriteCard(int cardId) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [cardId],
    );
    return result.isNotEmpty;
  }

  // Deck methods
  Future<List<Deck>> getDecks() async {
    final db = await instance.database;
    final result = await db.query('decks', orderBy: 'created_at DESC');

    List<Deck> decks = [];
    for (var deckMap in result) {
      final deck = Deck.fromDatabase(deckMap);

      // Get card count for each deck
      final cardCount = await getDeckCardCount(deck.id!);
      deck.cardCount = cardCount;

      decks.add(deck);
    }

    return decks;
  }

  Future<int> insertDeck(Deck deck) async {
    final db = await instance.database;
    return await db.insert('decks', deck.toDatabase());
  }

  Future<int> deleteDeck(int deckId) async {
    final db = await instance.database;

    // Delete deck cards first (cascade should handle this, but let's be explicit)
    await db.delete(
      'deck_cards',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );

    // Delete deck
    return await db.delete(
      'decks',
      where: 'id = ?',
      whereArgs: [deckId],
    );
  }

  Future<Deck?> getDeck(int deckId) async {
    final db = await instance.database;
    final result = await db.query(
      'decks',
      where: 'id = ?',
      whereArgs: [deckId],
    );

    if (result.isNotEmpty) {
      final deck = Deck.fromDatabase(result.first);
      deck.cardCount = await getDeckCardCount(deckId);
      return deck;
    }

    return null;
  }

  // Deck cards methods
  Future<int> addCardToDeck(int deckId, int cardId) async {
    final db = await instance.database;

    // Check if card already exists in deck
    final existing = await db.query(
      'deck_cards',
      where: 'deck_id = ? AND card_id = ?',
      whereArgs: [deckId, cardId],
    );

    if (existing.isNotEmpty) {
      // Update quantity
      return await db.update(
        'deck_cards',
        {
          'quantity': (existing.first['quantity'] as int) + 1,
        },
        where: 'deck_id = ? AND card_id = ?',
        whereArgs: [deckId, cardId],
      );
    } else {
      // Insert new card
      return await db.insert('deck_cards', {
        'deck_id': deckId,
        'card_id': cardId,
        'quantity': 1,
        'added_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<int> removeCardFromDeck(int deckId, int cardId) async {
    final db = await instance.database;

    // Check current quantity
    final existing = await db.query(
      'deck_cards',
      where: 'deck_id = ? AND card_id = ?',
      whereArgs: [deckId, cardId],
    );

    if (existing.isNotEmpty) {
      final currentQuantity = existing.first['quantity'] as int;

      if (currentQuantity > 1) {
        // Decrease quantity
        return await db.update(
          'deck_cards',
          {
            'quantity': currentQuantity - 1,
          },
          where: 'deck_id = ? AND card_id = ?',
          whereArgs: [deckId, cardId],
        );
      } else {
        // Remove completely
        return await db.delete(
          'deck_cards',
          where: 'deck_id = ? AND card_id = ?',
          whereArgs: [deckId, cardId],
        );
      }
    }

    return 0;
  }

  Future<List<YugiohCard>> getDeckCards(int deckId) async {
    final db = await instance.database;

    // Join deck_cards with favorites to get card details
    // Note: This assumes cards are stored in favorites table
    // In a real app, you might want a separate cards table
    final result = await db.rawQuery('''
      SELECT f.*, dc.quantity, dc.added_at as deck_added_at
      FROM deck_cards dc
      JOIN favorites f ON dc.card_id = f.id
      WHERE dc.deck_id = ?
      ORDER BY dc.added_at DESC
    ''', [deckId]);

    List<YugiohCard> cards = [];
    for (var cardMap in result) {
      final card = YugiohCard.fromDatabase(cardMap);
      // You can add quantity info to card if needed
      cards.add(card);
    }

    return cards;
  }

  Future<int> getDeckCardCount(int deckId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT SUM(quantity) as total
      FROM deck_cards
      WHERE deck_id = ?
    ''', [deckId]);

    return result.first['total'] as int? ?? 0;
  }

  Future<List<Map<String, dynamic>>> getDeckCardsWithQuantity(int deckId) async {
    final db = await instance.database;

    return await db.rawQuery('''
      SELECT f.*, dc.quantity, dc.added_at as deck_added_at
      FROM deck_cards dc
      JOIN favorites f ON dc.card_id = f.id
      WHERE dc.deck_id = ?
      ORDER BY dc.added_at DESC
    ''', [deckId]);
  }

  // Utility methods
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('deck_cards');
    await db.delete('decks');
    await db.delete('favorites');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
