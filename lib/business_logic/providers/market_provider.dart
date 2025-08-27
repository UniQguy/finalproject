import 'dart:async';
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/api_service.dart';

class MarketProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Stock> _stocks = [];
  final Map<String, double> _previousPrices = {};

  List<Stock> get stocks => List.unmodifiable(_stocks);

  MarketProvider({required String apiKey}) : _apiService = ApiService(apiKey: apiKey);

  Timer? _timer;

  void startFetchingStocks(List<String> symbols) {
    _fetchStocks(symbols);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchStocks(symbols));
  }

  Future<void> _fetchStocks(List<String> symbols) async {
    try {
      final fetchedStocks = await _apiService.fetchStocks(symbols);

      bool hasUpdate = false;

      for (var stock in fetchedStocks) {
        if (!_previousPrices.containsKey(stock.symbol)) {
          _previousPrices[stock.symbol] = stock.price;
          hasUpdate = true;
        } else if (_previousPrices[stock.symbol] != stock.price) {
          _previousPrices[stock.symbol] = stock.price;
          hasUpdate = true;
        }
      }

      if (hasUpdate) {
        _stocks = fetchedStocks;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching stocks: $e');
      debugPrint('$stackTrace');
      // TODO: Implement retry logic or UI feedback here.
    }
  }

  double? previousPrice(String symbol) => _previousPrices[symbol];

  double getPriceChangePercent(String symbol) {
    final currentStock = _stocks.firstWhere(
          (stock) => stock.symbol == symbol,
      orElse: () => Stock(symbol: symbol, company: '', price: 0, previousClose: 0, recentPrices: []),
    );
    final prevPrice = _previousPrices[symbol];

    if (currentStock.price == 0 || prevPrice == null || prevPrice == 0) {
      return 0.0;
    }

    return ((currentStock.price - prevPrice) / prevPrice) * 100;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
