import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/yugioh_card.dart';
import '../providers/favorites_provider.dart';
import '../screens/card_detail_screen.dart';
import '../screens/card_image_viewer.dart';
import '../services/preferences_service.dart';

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
            // Navigate to detailed card screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardDetailScreen(card: card),
              ),
            );
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
}
