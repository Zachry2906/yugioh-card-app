import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/yugioh_card.dart';
import '../providers/favorites_provider.dart';
import '../providers/deck_provider.dart';
import '../widgets/enhanced_price_widget.dart';
import '../screens/card_image_viewer.dart';

class CardDetailScreen extends StatelessWidget {
  final YugiohCard card;

  const CardDetailScreen({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
        actions: [
          IconButton(
            icon: Icon(Icons.fullscreen),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardImageViewer(card: card),
                ),
              );
            },
          ),
          Consumer<FavoritesProvider>(
            builder: (context, favProvider, child) {
              final isFav = favProvider.isFavoriteSync(card.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () {
                  if (isFav) {
                    favProvider.removeFromFavorites(card);
                  } else {
                    favProvider.addToFavorites(card);
                  }
                },
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'add_to_deck',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 8),
                    Text('Add to Deck'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'add_to_deck') {
                _showAddToDeckDialog(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Image
            if (card.cardImages.isNotEmpty)
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardImageViewer(card: card),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'card_${card.id}',
                    child: Container(
                      height: 300,
                      child: Image.network(
                        card.cardImages.first,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported, size: 100),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            
            SizedBox(height: 20),
            
            // Card Info
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow('Type', card.type),
                    if (card.race != null) _buildInfoRow('Race', card.race!),
                    if (card.attribute != null) _buildInfoRow('Attribute', card.attribute!),
                    if (card.level != null) _buildInfoRow('Level', card.level.toString()),
                    if (card.atk != null) _buildInfoRow('ATK', card.atk.toString()),
                    if (card.def != null) _buildInfoRow('DEF', card.def.toString()),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Enhanced Price Widget
            EnhancedPriceWidget(card: card),
            
            SizedBox(height: 16),
            
            // Description
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(card.desc),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddToDeckDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<DeckProvider>(
        builder: (context, deckProvider, child) {
          if (deckProvider.decks.isEmpty) {
            return AlertDialog(
              title: Text('No Decks Available'),
              content: Text('Create a deck first to add cards to it.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          }

          return AlertDialog(
            title: Text('Add to Deck'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: deckProvider.decks.map((deck) {
                return ListTile(
                  title: Text(deck.name),
                  subtitle: Text(deck.description),
                  onTap: () async {
                    await deckProvider.addCardToDeck(deck.id!, card);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${card.name} added to ${deck.name}')),
                    );
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }
}
