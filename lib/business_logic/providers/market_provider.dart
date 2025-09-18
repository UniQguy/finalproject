import 'dart:async';
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/api_service.dart';

/// Provides live market stock data fetching with periodic updates and state management.
class MarketProvider extends ChangeNotifier {
  final ApiService _apiService;
  final Duration fetchInterval;

  List<Stock> _stocks = [];
  final Map<String, double> _previousPrices = {};
  String? _errorMessage;

  /// Constructor accepting the API key and optional fetch interval (default 5s).
  MarketProvider({required String apiKey, this.fetchInterval = const Duration(seconds: 5)})
      : _apiService = ApiService(apiKey: apiKey);

  /// Returns an unmodifiable list of current stocks.
  List<Stock> get stocks => List.unmodifiable(_stocks);

  /// Returns the last error message, if any.
  String? get errorMessage => _errorMessage;

  Timer? _timer;

  /// Starts periodic fetching of stock data for the provided [symbols].
  void startFetchingStocks(List<String> symbols) {
    _fetchStocks(symbols);
    _timer?.cancel();
    _timer = Timer.periodic(fetchInterval, (_) => _fetchStocks(symbols));
  }

  /// Stops periodic fetching and disposes resources.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Fetches stocks from the API and updates state if prices change.
  Future<void> _fetchStocks(List<String> symbols) async {
    try {
      final fetchedStocks = await _apiService.fetchStocks(symbols);

      if (fetchedStocks.isEmpty) {
        return;
      }

      bool hasUpdate = false;
      for (var stock in fetchedStocks) {
        if (!_previousPrices.containsKey(stock.symbol) || _previousPrices[stock.symbol] != stock.price) {
          _previousPrices[stock.symbol] = stock.price;
          hasUpdate = true;
        }
      }

      if (hasUpdate) {
        _stocks = fetchedStocks;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _errorMessage = 'Error fetching stocks: $e';
      debugPrint(_errorMessage);
      debugPrint('$stackTrace');
      // Optional: Can notifyListeners() here if you want UI to show error immediately.
    }
  }

  /// Gets the previous price stored for a [symbol], or null if unknown.
  double? previousPrice(String symbol) => _previousPrices[symbol];

  /// Calculates price change percentage based on previous and current prices for [symbol].
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

  /// Clears all stored stocks, previous prices, and errors.
  void clear() {
    _stocks = [];
    _previousPrices.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
