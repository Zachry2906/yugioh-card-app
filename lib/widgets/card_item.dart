import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/yugioh_card.dart';
import '../providers/favorites_provider.dart';
import '../providers/deck_provider.dart';
import '../services/preferences_service.dart';
import '../services/currency_service.dart';
import '../screens/card_image_viewer.dart';

class CardItem extends StatelessWidget {
  final YugiohCard card;
  final Function(YugiohCard)? onTap;

  const CardItem({Key? key, required this.card, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          PreferencesService.setLastViewedCardId(card.id);
          if (onTap != null) {
            onTap!(card);
          } else {
            _showCardDetails(context);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: card.cardImages.isNotEmpty
                      ? GestureDetector(
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
                      child: Image.network(
                        card.cardImages.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported, size: 50),
                          );
                        },
                      ),
                    ),
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      card.type,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        if (card.atk != null)
                          Text(
                            'ATK: ${card.atk}',
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                        if (card.atk != null && card.def != null)
                          Text(' / ', style: TextStyle(fontSize: 10)),
                        if (card.def != null)
                          Text(
                            'DEF: ${card.def}',
                            style: TextStyle(fontSize: 10, color: Colors.blue),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        card.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  height: 200,
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        card.cardImages.first,
                                        fit: BoxFit.contain,
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.fullscreen, color: Colors.white, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                'View Full',
                                                style: TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                        _buildInfoRow('Type', card.type),
                        if (card.race != null) _buildInfoRow('Race', card.race!),
                        if (card.attribute != null) _buildInfoRow('Attribute', card.attribute!),
                        if (card.level != null) _buildInfoRow('Level', card.level.toString()),
                        if (card.atk != null) _buildInfoRow('ATK', card.atk.toString()),
                        if (card.def != null) _buildInfoRow('DEF', card.def.toString()),

                        // Bagian harga kartu
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Card Prices',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildCardPrices(),

                        SizedBox(height: 16),
                        Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(card.desc),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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

  Widget _buildCardPrices() {
    if (card.cardPrices == null) {
      return Text('Price information not available');
    }

    return FutureBuilder<double>(
        future: CurrencyService.getUsdToIdrRate(),
        builder: (context, snapshot) {
          final exchangeRate = snapshot.data ?? 15500.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceRow(
                  'TCGPlayer',
                  _getPriceUsd(card.cardPrices?['tcgplayer_price']),
                  _getPriceIdr(card.cardPrices?['tcgplayer_price'], exchangeRate)
              ),
              _buildPriceRow(
                  'Cardmarket',
                  _getPriceUsd(card.cardPrices?['cardmarket_price']),
                  _getPriceIdr(card.cardPrices?['cardmarket_price'], exchangeRate)
              ),
              _buildPriceRow(
                  'eBay',
                  _getPriceUsd(card.cardPrices?['ebay_price']),
                  _getPriceIdr(card.cardPrices?['ebay_price'], exchangeRate)
              ),
              _buildPriceRow(
                  'Amazon',
                  _getPriceUsd(card.cardPrices?['amazon_price']),
                  _getPriceIdr(card.cardPrices?['amazon_price'], exchangeRate)
              ),
              SizedBox(height: 4),
              Text(
                'Exchange rate: 1 USD = ${CurrencyService.formatIdr(exchangeRate)}',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          );
        }
    );
  }

  String _getPriceUsd(String? priceStr) {
    if (priceStr == null) return 'N/A';
    try {
      final price = double.parse(priceStr);
      return CurrencyService.formatUsd(price);
    } catch (e) {
      return 'N/A';
    }
  }

  String _getPriceIdr(String? priceStr, double exchangeRate) {
    if (priceStr == null) return 'N/A';
    try {
      final priceUsd = double.parse(priceStr);
      final priceIdr = priceUsd * exchangeRate;
      return CurrencyService.formatIdr(priceIdr);
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildPriceRow(String marketplace, String usdPrice, String idrPrice) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$marketplace:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(usdPrice),
                Text(idrPrice),
              ],
            ),
          ),
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
