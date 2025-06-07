import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/card_provider.dart';
import '../widgets/card_grid.dart';

class CardsScreen extends StatefulWidget {
  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final cardProvider = context.read<CardProvider>();
      if (cardProvider.hasMore && !cardProvider.isLoading) {
        cardProvider.loadCards();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yu-Gi-Oh! Cards'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              context.read<CardProvider>().loadCardsByType(value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Monster', child: Text('Monster Cards')),
              PopupMenuItem(value: 'Spell', child: Text('Spell Cards')),
              PopupMenuItem(value: 'Trap', child: Text('Trap Cards')),
            ],
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer<CardProvider>(
        builder: (context, cardProvider, child) {
          if (cardProvider.cards.isEmpty && cardProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (cardProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading cards',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(cardProvider.error),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => cardProvider.loadCards(refresh: true),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => cardProvider.loadCards(refresh: true),
            child: CardGrid(
              cards: cardProvider.cards,
              scrollController: _scrollController,
              isLoading: cardProvider.isLoading,
            ),
          );
        },
      ),
    );
  }
}