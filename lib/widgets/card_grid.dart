import 'package:flutter/material.dart';
import '../models/yugioh_card.dart';
import '../widgets/card_item.dart';

class CardGrid extends StatelessWidget {
  final List<YugiohCard> cards;
  final ScrollController? scrollController;
  final bool isLoading;

  const CardGrid({
    Key? key,
    required this.cards,
    this.scrollController,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return CardItem(card: cards[index]);
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
