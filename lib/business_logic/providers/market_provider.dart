import 'dart:async';
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/api_service.dart';

/// Provides stock market data fetching and state management.
/// Periodically fetches stock prices and tracks previous values for change calculation.
class MarketProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Stock> _stocks = [];
  final Map<String, double> _previousPrices = {};

  /// Immutable list of fetched stocks.
  List<Stock> get stocks => List.unmodifiable(_stocks);

  MarketProvider({required String apiKey}) : _apiService = ApiService(apiKey: apiKey);

  Timer? _timer;

  /// Starts periodic fetching of stock data for the given symbols every 5 seconds.
  void startFetchingStocks(List<String> symbols) {
    _fetchStocks(symbols);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchStocks(symbols));
  }

  /// Fetches latest stock data from API and updates internal state.
  Future<void> _fetchStocks(List<String> symbols) async {
    try {
      final fetchedStocks = await _apiService.fetchStocks(symbols);

      // Initialize previous price if not set for new stocks.
      for (var stock in fetchedStocks) {
        _previousPrices.putIfAbsent(stock.symbol, () => stock.price);
      }

      _stocks = fetchedStocks;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error fetching stocks: $e');
      debugPrint('$stackTrace');
      // Optional: Implement retry logic or user notification here.
    }
  }

  /// Returns the stored previous price for a stock symbol if available.
  double? previousPrice(String symbol) => _previousPrices[symbol];

  /// Calculates the price change percentage compared to the previous cached price.
  /// Returns 0.0 if no valid data available.
  double getPriceChangePercent(String symbol) {
    final currentStock = _stocks.firstWhere(
          (stock) => stock.symbol == symbol,
      orElse: () => Stock(
        symbol: symbol,
        company: '',
        price: 0,
        previousClose: 0,
        recentPrices: [],
      ),
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
