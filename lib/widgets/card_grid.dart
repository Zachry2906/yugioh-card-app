import 'package:flutter/material.dart';
import '../models/yugioh_card.dart';
import 'card_item.dart';

class CardGrid extends StatelessWidget {
  final List<YugiohCard> cards;
  final ScrollController? scrollController;
  final bool isLoading;
  final Function(YugiohCard)? onCardTap;

  const CardGrid({
    Key? key,
    required this.cards,
    this.scrollController,
    required this.isLoading,
    this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return CardItem(
                card: cards[index],
                onTap: onCardTap,
              );
            },
          ),
        ),
        if (isLoading)
          Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}