import 'package:flutter/material.dart';
import '../models/yugioh_card.dart';
import '../services/enhanced_currency_service.dart';

class EnhancedPriceWidget extends StatefulWidget {
  final YugiohCard card;

  const EnhancedPriceWidget({Key? key, required this.card}) : super(key: key);

  @override
  _EnhancedPriceWidgetState createState() => _EnhancedPriceWidgetState();
}

class _EnhancedPriceWidgetState extends State<EnhancedPriceWidget> {
  String _selectedCurrency = 'IDR';
  Map<String, double> _exchangeRates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCurrency();
  }

  Future<void> _initializeCurrency() async {
    final defaultCurrency = await EnhancedCurrencyService.getDefaultCurrency();
    final rates = await EnhancedCurrencyService.getAllExchangeRates();

    if (mounted) {
      setState(() {
        _selectedCurrency = defaultCurrency;
        _exchangeRates = rates;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Card Prices',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedCurrency,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                      EnhancedCurrencyService.setDefaultCurrency(value);
                    }
                  },
                  items: ['USD', 'IDR', 'JPY'].map((currency) {
                    return DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (widget.card.cardPrices != null) ...[
              _buildPriceRow('TCGPlayer', widget.card.cardPrices?['tcgplayer_price']),
              _buildPriceRow('Cardmarket', widget.card.cardPrices?['cardmarket_price']),
              _buildPriceRow('eBay', widget.card.cardPrices?['ebay_price']),
              _buildPriceRow('Amazon', widget.card.cardPrices?['amazon_price']),
              SizedBox(height: 8),
              _buildExchangeRateInfo(),
            ] else
              Text('Price information not available'),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String marketplace, String? priceStr) {
    return FutureBuilder<String>(
      future: _convertPrice(priceStr),
      builder: (context, snapshot) {
        final convertedPrice = snapshot.data ?? 'N/A';

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                marketplace,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                convertedPrice,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExchangeRateInfo() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exchange Rates (Base: USD)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRateChip('USD', _exchangeRates['USD'] ?? 1.0),
              _buildRateChip('IDR', _exchangeRates['IDR'] ?? 15500.0),
              _buildRateChip('JPY', _exchangeRates['JPY'] ?? 150.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateChip(String currency, double rate) {
    final isSelected = currency == _selectedCurrency;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.purple[100] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.purple[300]! : Colors.grey[300]!,
        ),
      ),
      child: Text(
        '1 USD = ${EnhancedCurrencyService.formatCurrency(rate, currency)}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.purple[800] : Colors.grey[700],
        ),
      ),
    );
  }

  Future<String> _convertPrice(String? priceStr) async {
    if (priceStr == null) return 'N/A';

    try {
      final usdPrice = double.parse(priceStr);
      final convertedAmount = await EnhancedCurrencyService.convertCurrency(
          usdPrice,
          'USD',
          _selectedCurrency
      );
      return EnhancedCurrencyService.formatCurrency(convertedAmount, _selectedCurrency);
    } catch (e) {
      return 'N/A';
    }
  }
}
