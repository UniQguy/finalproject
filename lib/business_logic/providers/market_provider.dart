import 'dart:async';
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../models/candle_data.dart';
import '../services/api_service.dart';

class MarketProvider extends ChangeNotifier {
  final ApiService _apiService;
  final Duration fetchInterval;

  List<Stock> _stocks = [];
  final Map<String, double> _previousPrices = {};
  final Map<String, List<double>> _recentPrices = {};  // Added to track recentPrices per symbol
  String? _errorMessage;
  final Map<String, List<CandleData>> _candlesticks = {};

  MarketProvider({required String apiKey, this.fetchInterval = const Duration(seconds: 5)})
      : _apiService = ApiService(apiKey: apiKey);

  List<Stock> get stocks => List.unmodifiable(_stocks);
  String? get errorMessage => _errorMessage;
  List<CandleData> candlesticksForSymbol(String symbol) => _candlesticks[symbol] ?? [];
  List<double> recentPricesForSymbol(String symbol) => _recentPrices[symbol] ?? [];
  Timer? _timer;

  void startFetchingStocks(List<String> symbols) {
    _fetchStocks(symbols);
    for (var symbol in symbols) {
      fetchCandlestickData(symbol);
    }
    _timer?.cancel();
    _timer = Timer.periodic(fetchInterval, (_) => _fetchStocks(symbols));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStocks(List<String> symbols) async {
    try {
      final stocks = await _apiService.fetchStocks(symbols);
      if (stocks.isEmpty) return;
      bool updated = false;
      for (var s in stocks) {
        if (!_previousPrices.containsKey(s.symbol) || _previousPrices[s.symbol] != s.price) {
          _previousPrices[s.symbol] = s.price;
          updated = true;
        }
      }
      if (updated) {
        _stocks = stocks;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e, stack) {
      _errorMessage = 'Error fetching stocks: $e';
      debugPrint(_errorMessage);
      debugPrint('$stack');
    }
  }

  Future<void> fetchCandlestickData(String symbol, {String resolution = 'D', int days = 30}) async {
    try {
      final to = DateTime.now();
      final from = to.subtract(Duration(days: days));
      final candles = await _apiService.fetchCandles(
        symbol: symbol,
        resolution: resolution,
        from: from.millisecondsSinceEpoch ~/ 1000,
        to: to.millisecondsSinceEpoch ~/ 1000,
      );
      _candlesticks[symbol] = candles;
      notifyListeners();
    } catch (e, stack) {
      debugPrint('Error fetching candlestick data for $symbol: $e');
      debugPrint('$stack');
    }
  }

  /// New method: fetch recent price history for a stock symbol over a given period.
  Future<void> fetchPriceHistory(String symbol, String period) async {
    try {
      // Convert period string to days or resolution for API
      int days = 1; // Default 1 day
      String resolution = 'D'; // Default daily

      switch (period) {
        case '1D':
          days = 1;
          resolution = '1';
          break;
        case '5D':
          days = 5;
          resolution = '15';
          break;
        case '1M':
          days = 30;
          resolution = 'D';
          break;
        case '6M':
          days = 180;
          resolution = 'D';
          break;
        case 'YTD':
          final now = DateTime.now();
          days = DateTime(now.year, now.month, now.day).difference(DateTime(now.year, 1, 1)).inDays;
          resolution = 'D';
          break;
        case '1Y':
          days = 365;
          resolution = 'D';
          break;
        case '5Y':
          days = 365 * 5;
          resolution = 'W';
          break;
        case 'MAX':
          days = 365 * 10; // Arbitrary 10 years max
          resolution = 'W';
          break;
        default:
          days = 30;
          resolution = 'D';
      }

      final to = DateTime.now();
      final from = to.subtract(Duration(days: days));

      final candles = await _apiService.fetchCandles(
        symbol: symbol,
        resolution: resolution,
        from: from.millisecondsSinceEpoch ~/ 1000,
        to: to.millisecondsSinceEpoch ~/ 1000,
      );

      // Extract close prices from candles for chart
      final closes = candles.map((c) => c.close).toList();

      _recentPrices[symbol] = closes;

      // Update the matching stock's recentPrices if present
      final stockIndex = _stocks.indexWhere((s) => s.symbol == symbol);
      if (stockIndex != -1) {
        final stock = _stocks[stockIndex];
        _stocks[stockIndex] = Stock(
          symbol: stock.symbol,
          company: stock.company,
          price: stock.price,
          previousClose: stock.previousClose,
          recentPrices: closes,
          candles: candles,
        );
      }

      notifyListeners();
    } catch (e, stack) {
      debugPrint('Error fetching price history for $symbol: $e');
      debugPrint('$stack');
    }
  }

  double? previousPrice(String symbol) => _previousPrices[symbol];

  double getPriceChangePercent(String symbol) {
    final curStock = _stocks.firstWhere(
          (s) => s.symbol == symbol,
      orElse: () => Stock(symbol: symbol, company: '', price: 0, previousClose: 0, recentPrices: [], candles: []),
    );
    final prev = _previousPrices[symbol];
    if (curStock.price == 0 || prev == null || prev == 0) return 0.0;
    return ((curStock.price - prev) / prev) * 100;
  }

  void clear() {
    _stocks = [];
    _previousPrices.clear();
    _candlesticks.clear();
    _recentPrices.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
