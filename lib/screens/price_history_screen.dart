import 'package:flutter/material.dart';
import '../models/yugioh_card.dart';
import '../services/currency_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PriceHistoryScreen extends StatefulWidget {
  final YugiohCard card;

  const PriceHistoryScreen({Key? key, required this.card}) : super(key: key);

  @override
  _PriceHistoryScreenState createState() => _PriceHistoryScreenState();
}

class _PriceHistoryScreenState extends State<PriceHistoryScreen> {
  List<Map<String, dynamic>> _priceHistory = [];
  bool _isLoading = true;
  String _selectedMarketplace = 'tcgplayer';
  bool _showInIdr = false;
  double _exchangeRate = 15500.0;

  @override
  void initState() {
    super.initState();
    _loadExchangeRate();
    _loadPriceHistory();
  }

  Future<void> _loadExchangeRate() async {
    final rate = await CurrencyService.getUsdToIdrRate();
    setState(() {
      _exchangeRate = rate;
    });
  }

  Future<void> _loadPriceHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(Duration(seconds: 1));

      double? currentPrice;
      if (widget.card.cardPrices != null) {
        try {
          currentPrice = double.parse(widget.card.cardPrices?['${_selectedMarketplace}_price'] ?? '0');
        } catch (e) {
          currentPrice = 0;
        }
      }

      final now = DateTime.now();
      final history = List.generate(30, (index) {
        final date = now.subtract(Duration(days: 29 - index));
        // Generate a random price fluctuation within 20% of current price
        final randomFactor = 0.8 + (index / 30) * 0.4; // Trending upward for demo
        final price = currentPrice != null && currentPrice > 0 
            ? currentPrice * randomFactor
            : (index + 1) * 0.5; // Fallback if no current price
            
        return {
          'date': date.toString().substring(0, 10),
          'price': price,
        };
      });
      
      setState(() {
        _priceHistory = history;
        _isLoading = false;
      });
      
      // Save mock history to SharedPreferences for persistence
      _savePriceHistory(history);
      
    } catch (e) {
      print('Error loading price history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _savePriceHistory(List<Map<String, dynamic>> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'price_history_${widget.card.id}_$_selectedMarketplace';
      await prefs.setString(key, json.encode(history));
    } catch (e) {
      print('Error saving price history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Price History'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.card.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Marketplace selector
            Row(
              children: [
                Text('Marketplace: ', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedMarketplace,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMarketplace = value;
                      });
                      _loadPriceHistory();
                    }
                  },
                  items: [
                    DropdownMenuItem(value: 'tcgplayer', child: Text('TCGPlayer')),
                    DropdownMenuItem(value: 'cardmarket', child: Text('Cardmarket')),
                    DropdownMenuItem(value: 'ebay', child: Text('eBay')),
                    DropdownMenuItem(value: 'amazon', child: Text('Amazon')),
                  ],
                ),
                Spacer(),
                // Currency toggle
                Row(
                  children: [
                    Text('Show in IDR'),
                    Switch(
                      value: _showInIdr,
                      onChanged: (value) {
                        setState(() {
                          _showInIdr = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Current price
            _buildCurrentPrice(),
            
            SizedBox(height: 24),
            
            // Price chart
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildPriceChart(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCurrentPrice() {
    String? priceStr = widget.card.cardPrices?['${_selectedMarketplace}_price'];
    double? price;
    
    try {
      price = priceStr != null ? double.parse(priceStr) : null;
    } catch (e) {
      price = null;
    }
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Price',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'USD:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  CurrencyService.formatUsd(price),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'IDR:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  CurrencyService.formatIdr(price != null ? price * _exchangeRate : null),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPriceChart() {
    if (_priceHistory.isEmpty) {
      return Center(
        child: Text('No price history available'),
      );
    }
    
    final spots = _priceHistory.asMap().entries.map((entry) {
      final price = _showInIdr 
          ? entry.value['price'] * _exchangeRate 
          : entry.value['price'];
      return FlSpot(entry.key.toDouble(), price);
    }).toList();
    
    final minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price History (Last 30 Days)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      String text = _showInIdr
                          ? 'Rp ${value.toInt()}'
                          : '\$${value.toStringAsFixed(2)}';
                      return Text(
                        text,
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      // Show dates at intervals
                      if (value.toInt() % 7 == 0 && value.toInt() < _priceHistory.length) {
                        final date = _priceHistory[value.toInt()]['date'].toString().substring(5);
                        return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            date,
                            style: TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              minX: 0,
              maxX: (_priceHistory.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.purple[800],
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.purple.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
