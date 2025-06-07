import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deck.dart';
import '../models/yugioh_card.dart';
import '../providers/deck_provider.dart';
import '../widgets/card_item.dart';

class DeckDetailScreen extends StatefulWidget {
  final Deck deck;

  const DeckDetailScreen({Key? key, required this.deck}) : super(key: key);

  @override
  _DeckDetailScreenState createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  List<Map<String, dynamic>> _deckCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeckCards();
  }

  Future<void> _loadDeckCards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final deckProvider = context.read<DeckProvider>();
      final cardsWithQuantity = await deckProvider.getDeckCardsWithQuantity(widget.deck.id!);

      setState(() {
        _deckCards = cardsWithQuantity;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading deck cards: $e')),
      );
    }
  }

  Future<void> _removeCard(YugiohCard card) async {
    try {
      await context.read<DeckProvider>().removeCardFromDeck(widget.deck.id!, card.id);
      await _loadDeckCards(); // Reload to update quantities

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${card.name} removed from deck')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing card: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteDeckDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Deck info header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.purple[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.deck.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${_deckCards.length} cards in deck',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
          ),

          // Cards list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _deckCards.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.collections_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No cards in this deck',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add cards from your favorites or search',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _deckCards.length,
              itemBuilder: (context, index) {
                final cardData = _deckCards[index];
                final card = YugiohCard.fromDatabase(cardData);
                final quantity = cardData['quantity'] as int;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: card.cardImages.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        card.cardImages.first,
                        width: 40,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 40,
                            height: 56,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    )
                        : Container(
                      width: 40,
                      height: 56,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported),
                    ),
                    title: Text(
                      card.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(card.type),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'x$quantity',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[800],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeCard(card),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to card detail if needed
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDeckDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Deck'),
          content: Text('Are you sure you want to delete "${widget.deck.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await context.read<DeckProvider>().deleteDeck(widget.deck.id!);
                  Navigator.of(context).pop(); // Go back to decks list
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting deck: $e')),
                  );
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
