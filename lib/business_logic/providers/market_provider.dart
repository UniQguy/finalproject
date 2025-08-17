import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/stock.dart';

class MarketProvider extends ChangeNotifier {
  final Random _rng = Random();

  /// Initial mock data — replace with API data if needed
  List<Stock> stocks = [
    Stock(symbol: 'AAPL', name: 'Apple Inc.', price: 150.0, previousClose: 148.0),
    Stock(symbol: 'GOOGL', name: 'Alphabet Inc.', price: 2800.0, previousClose: 2750.0),
    Stock(symbol: 'AMZN', name: 'Amazon.com Inc.', price: 3300.0, previousClose: 3250.0),
    Stock(symbol: 'TSLA', name: 'Tesla Inc.', price: 700.0, previousClose: 690.0),
    Stock(symbol: 'MSFT', name: 'Microsoft Corp.', price: 300.0, previousClose: 295.0),
  ];

  Timer? _priceTimer;

  MarketProvider() {
    _startMockPriceStream();
  }

  /// Simulates live price updates — swap this with an API integration later
  void _startMockPriceStream() {
    _priceTimer?.cancel();
    _priceTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      for (var stock in stocks) {
        // Random small change ± ~1%
        final changePercent = (_rng.nextDouble() - 0.5) / 50;
        final newPrice = ((stock.price * (1 + changePercent))
            .clamp(1, double.infinity))
            .toDouble(); // ensure double type

        stock.updatePrice(newPrice);
      }
      notifyListeners();
    });
  }

  /// Manual update if pulling from an API
  void updateStockPrice(String symbol, double newPrice) {
    final idx = stocks.indexWhere((s) => s.symbol == symbol);
    if (idx >= 0) {
      stocks[idx].updatePrice(newPrice);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    super.dispose();
  }
}
