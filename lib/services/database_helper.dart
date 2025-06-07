import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/yugioh_card.dart';
import '../models/deck.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _isInitialized = false;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (_database != null) return _database!;

    try {
      _database = await _initDB('yugioh.db');
      _isInitialized = true;
      return _database!;
    } catch (e) {
      print('Database initialization failed: $e');
      _isInitialized = false;
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future _createDB(Database db, int version) async {
    try {

      await db.execute('''
        CREATE TABLE favorites (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          desc TEXT NOT NULL,
          atk INTEGER,
          def INTEGER,
          level INTEGER,
          race TEXT,
          attribute TEXT,
          image_url TEXT,
          card_prices TEXT
        )
      ''');

      // Decks table
      await db.execute('''
        CREATE TABLE decks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');

      // Deck cards table (junction table)
      await db.execute('''
        CREATE TABLE deck_cards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          deck_id INTEGER NOT NULL,
          card_id INTEGER NOT NULL,
          card_name TEXT NOT NULL,
          card_type TEXT NOT NULL,
          card_desc TEXT NOT NULL,
          card_atk INTEGER NOT NULL,
          card_def INTEGER NOT NULL,
          card_level INTEGER NOT NULL,
          card_race TEXT NOT NULL,
          card_attribute TEXT NOT NULL,
          card_image_url TEXT NOT NULL,
          card_prices TEXT NOT NULL,
          FOREIGN KEY (deck_id) REFERENCES decks (id) ON DELETE CASCADE
        )
      ''');
    } catch (e) {
      print('Error creating database tables: $e');
      rethrow;
    }
  }

  bool get isAvailable => _isInitialized && _database != null;

  Future<int> addToFavorites(YugiohCard card) async {
    try {
      final db = await instance.database;
      if (db == null) return -1;

      final data = card.toJson();

      if (data['card_prices'] != null) {
        data['card_prices'] = json.encode(data['card_prices']);
      }

      return await db.insert('favorites', data, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error adding to favorites: $e');
      return -1;
    }
  }

  Future<List<YugiohCard>> getFavorites() async {
    try {
      final db = await instance.database;
      if (db == null) return [];

      final result = await db.query('favorites');
      return result.map((json) => YugiohCard.fromDatabase(json)).toList();
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  Future<int> removeFromFavorites(int cardId) async {
    try {
      final db = await instance.database;
      if (db == null) return -1;

      return await db.delete('favorites', where: 'id = ?', whereArgs: [cardId]);
    } catch (e) {
      print('Error removing from favorites: $e');
      return -1;
    }
  }

  Future<bool> isFavorite(int cardId) async {
    try {
      final db = await instance.database;
      if (db == null) return false;

      final result = await db.query(
        'favorites',
        where: 'id = ?',
        whereArgs: [cardId],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  Future<int> createDeck(Deck deck) async {
    try {
      final db = await instance.database;
      if (db == null) return -1;

      return await db.insert('decks', deck.toJson());
    } catch (e) {
      print('Error creating deck: $e');
      return -1;
    }
  }

  Future<List<Deck>> getDecks() async {
    try {
      final db = await instance.database;
      if (db == null) return [];

      final result = await db.query('decks', orderBy: 'created_at DESC');
      return result.map((json) => Deck.fromJson(json)).toList();
    } catch (e) {
      print('Error getting decks: $e');
      return [];
    }
  }

  Future<int> updateDeck(Deck deck) async {
    try {
      final db = await instance.database;
      if (db == null) return -1;

      return await db.update(
        'decks',
        deck.toJson(),
        where: 'id = ?',
        whereArgs: [deck.id],
      );
    } catch (e) {
      print('Error updating deck: $e');
      return -1;
    }
  }

  Future<int> deleteDeck(int deckId) async {
    try {
      final db = await instance.database;
      if (db == null) return -1;

      return await db.delete('decks', where: 'id = ?', whereArgs: [deckId]);
    } catch (e) {
      print('Error deleting deck: $e');
      return -1;
    }
  }

  // Deck Cards CRUD with error handling
  Future<int> addCardToDeck(int deckId, YugiohCard card) async {
    try {
      final db = await instance.database;
      if (db == null) return -1;

      String? cardPricesJson;

      if (card.cardPrices != null) {
        cardPricesJson = json.encode(card.cardPrices);
      }

      return await db.insert('deck_cards', {
        'deck_id': deckId,
        'card_id': card.id,
        'card_name': card.name,
        'card_type': card.type,
        'card_desc': card.desc,
        'card_atk': card.atk,
        'card_def': card.def,
        'card_level': card.level,
        'card_race': card.race,
        'card_attribute': card.attribute,
        'card_image_url': card.cardImages.isNotEmpty ? card.cardImages.first : '',
        'card_prices': cardPricesJson,
      });
    } catch (e) {
      print('Error adding card to deck: $e');
      return -1;
    }
  }

  Future<List<YugiohCard>> getDeckCards(int deckId) async {
    try {
      final db = await instance.database;
      if (db == null) return [];

      final result = await db.query(
        'deck_cards',
        where: 'deck_id = ?',
        whereArgs: [deckId],
      );

      return result.map((json) => YugiohCard.fromDatabase({
        'id': json['card_id'],
        'name': json['card_name'],
        'type': json['card_type'],
        'desc': json['card_desc'],
        'atk': json['card_atk'],
        'def': json['card_def'],
        'level': json['card_level'],
        'race': json['card_race'],
        'attribute': json['card_attribute'],
        'image_url': json['card_image_url'],
        'card_prices': json['card_prices'],
      })).toList();
    } catch (e) {
      print('Error getting deck cards: $e');
      return [];
    }
  }

  Future<int> removeCardFromDeck(int deckId, int cardId) async {
    try {
      final db = await instance.database;
      if (db == null) return -1;

      return await db.delete(
        'deck_cards',
        where: 'deck_id = ? AND card_id = ?',
        whereArgs: [deckId, cardId],
      );
    } catch (e) {
      print('Error removing card from deck: $e');
      return -1;
    }
  }

  Future close() async {
    final db = await instance.database;
    if (db != null) {
      await db.close();
    }
  }
}
