import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../business_logic/models/stock.dart';
import '../../business_logic/services/api_service.dart';

class TradePage extends StatefulWidget {
  final String stockSymbol;

  const TradePage({super.key, required this.stockSymbol});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  final ApiService _apiService = ApiService(apiKey: 'dummmy_key');
  Stock? _stock;
  bool _isLoading = true;
  bool _isCall = true;
  int _quantity = 1;
  String? _error;

  final TextEditingController _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _fetchStock();
  }

  Future<void> _fetchStock() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stock = await _apiService.fetchStockQuote(widget.stockSymbol);
      if (mounted) {
        setState(() {
          _stock = stock;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load stock data.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _placeOrder() {
    if (_stock == null || _quantity <= 0) return;
    Navigator.of(context).pushNamed(
      '/order-confirmation/${_stock!.symbol}/$_quantity/$_isCall',
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _isCall ? Colors.greenAccent : Colors.redAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Place Order - ${widget.stockSymbol}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.purpleAccent,
        ),
      )
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            _error!,
            style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Price: ₹${_stock!.price.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Call'),
                  selected: _isCall,
                  selectedColor: Colors.greenAccent,
                  backgroundColor: Colors.white24,
                  labelStyle: TextStyle(
                    color: _isCall ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    setState(() {
                      _isCall = true;
                    });
                  },
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Put'),
                  selected: !_isCall,
                  selectedColor: Colors.redAccent,
                  backgroundColor: Colors.white24,
                  labelStyle: TextStyle(
                    color: !_isCall ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    setState(() {
                      _isCall = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter quantity',
                hintStyle: const TextStyle(color: Colors.white54),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (val) {
                final q = int.tryParse(val);
                if (q != null && q > 0) {
                  setState(() {
                    _quantity = q;
                  });
                } else {
                  setState(() {
                    _quantity = 0;
                  });
                }
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _quantity > 0 ? _placeOrder : null,
                child: Text(
                  'Place Order - ₹${(_stock!.price * _quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
