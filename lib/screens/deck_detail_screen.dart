import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deck.dart';
import '../models/yugioh_card.dart';
import '../providers/deck_provider.dart';
import '../widgets/card_grid.dart';

class DeckDetailScreen extends StatefulWidget {
  final Deck deck;

  const DeckDetailScreen({Key? key, required this.deck}) : super(key: key);

  @override
  _DeckDetailScreenState createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  List<YugiohCard> _deckCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeckCards();
  }

  Future<void> _loadDeckCards() async {
    final cards = await context.read<DeckProvider>().getDeckCards(widget.deck.id!);
    setState(() {
      _deckCards = cards;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.name),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () => _showDeckInfo(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _deckCards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.collections_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Empty Deck',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add cards to this deck from the main cards screen',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : CardGrid(
                  cards: _deckCards,
                  isLoading: false,
                  onCardTap: (card) => _showCardOptions(context, card),
                ),
    );
  }

  void _showDeckInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.deck.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(widget.deck.description.isEmpty ? 'No description' : widget.deck.description),
            SizedBox(height: 16),
            Text('Cards: ${_deckCards.length}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Created: ${_formatDate(widget.deck.createdAt)}', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCardOptions(BuildContext context, YugiohCard card) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.remove_circle, color: Colors.red),
              title: Text('Remove from Deck'),
              onTap: () async {
                Navigator.pop(context);
                await context.read<DeckProvider>().removeCardFromDeck(widget.deck.id!, card.id);
                _loadDeckCards();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${card.name} removed from deck')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Card Details'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to card detail screen
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}