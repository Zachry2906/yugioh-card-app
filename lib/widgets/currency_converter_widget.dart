import 'package:flutter/material.dart';
import '../services/enhanced_currency_service.dart';

class CurrencyConverterWidget extends StatefulWidget {
  @override
  _CurrencyConverterWidgetState createState() => _CurrencyConverterWidgetState();
}

class _CurrencyConverterWidgetState extends State<CurrencyConverterWidget> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  String _result = '';
  Map<String, double> _exchangeRates = {};

  @override
  void initState() {
    super.initState();
    _loadExchangeRates();
  }

  Future<void> _loadExchangeRates() async {
    final rates = await EnhancedCurrencyService.getAllExchangeRates();
    if (mounted) {
      setState(() {
        _exchangeRates = rates;
      });
    }
  }

  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) return;

    try {
      final amount = double.parse(_amountController.text);
      final convertedAmount = await EnhancedCurrencyService.convertCurrency(
          amount,
          _fromCurrency,
          _toCurrency
      );

      setState(() {
        _result = EnhancedCurrencyService.formatCurrency(convertedAmount, _toCurrency);
      });
    } catch (e) {
      setState(() {
        _result = 'Invalid amount';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currency Converter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Amount input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: EnhancedCurrencyService.getCurrencySymbol(_fromCurrency),
              ),
              onChanged: (value) => _convertCurrency(),
            ),

            SizedBox(height: 16),

            // Currency selectors
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromCurrency,
                    decoration: InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                    items: ['USD', 'IDR', 'JPY'].map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _fromCurrency = value;
                        });
                        _convertCurrency();
                      }
                    },
                  ),
                ),

                SizedBox(width: 16),

                IconButton(
                  icon: Icon(Icons.swap_horiz),
                  onPressed: () {
                    setState(() {
                      final temp = _fromCurrency;
                      _fromCurrency = _toCurrency;
                      _toCurrency = temp;
                    });
                    _convertCurrency();
                  },
                ),

                SizedBox(width: 16),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toCurrency,
                    decoration: InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                    items: ['USD', 'IDR', 'JPY'].map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _toCurrency = value;
                        });
                        _convertCurrency();
                      }
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Result
            if (_result.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Converted Amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.purple[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _result,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[800],
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 16),

            // Exchange rates info
            if (_exchangeRates.isNotEmpty)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Exchange Rates',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1 USD = ${EnhancedCurrencyService.formatCurrency(_exchangeRates['IDR'] ?? 0, 'IDR')}',
                      style: TextStyle(fontSize: 11),
                    ),
                    Text(
                      '1 USD = ${EnhancedCurrencyService.formatCurrency(_exchangeRates['JPY'] ?? 0, 'JPY')}',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
