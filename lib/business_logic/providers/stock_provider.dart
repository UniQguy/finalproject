import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/api_service.dart';
import '../models/candle_data.dart';


/// Provides stock data fetching and state management with Finnhub API integration.
class StockProvider extends ChangeNotifier {
  final ApiService _apiService;

  // List of currently fetched stocks.
  List<Stock> _stocks = [];

  // Loading state for stock list fetching.
  bool _isLoading = false;

  // Error message for stock list fetching.
  String? _errorMessage;

  // Map from symbol to list of candlestick data.
  Map<String, List<CandleData>> _candlesMap = {};

  // Loading state for candle data fetching.
  bool _candlesLoading = false;

  // Error message for candle data fetching.
  String? _candlesErrorMessage;

  /// Constructor accepting an API key to initialize the ApiService.
  StockProvider({required String apiKey}) : _apiService = ApiService(apiKey: apiKey);

  /// Returns an unmodifiable list of the latest fetched stocks.
  List<Stock> get stocks => List.unmodifiable(_stocks);

  /// Is stock data currently being fetched.
  bool get isLoading => _isLoading;

  /// Stores any error message from the last fetch attempt.
  String? get errorMessage => _errorMessage;

  /// Returns candle data for a given symbol or an empty list if none present.
  List<CandleData> getCandles(String symbol) => _candlesMap[symbol] ?? [];

  /// Is candle data loading currently.
  bool get candlesLoading => _candlesLoading;

  /// Latest error message related to candle fetching.
  String? get candlesErrorMessage => _candlesErrorMessage;

  /// Fetches stock data for the given list of symbols from the API.
  /// On success, updates the internal stocks list and notifies listeners.
  /// On failure, populates the errorMessage and clears stocks.
  Future<void> fetchStocks(List<String> symbols) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Stock> fetchedStocks = await _apiService.fetchStocks(symbols);
      _stocks = fetchedStocks;
    } catch (error, stackTrace) {
      _errorMessage = 'Failed to fetch stocks: $error';
      debugPrint(_errorMessage);
      debugPrint('$stackTrace');
      _stocks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the current stock list and error message.
  void clear() {
    _stocks = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Convenience method to start fetching stocks.
  void startFetchingStocks(List<String> symbols) {
    fetchStocks(symbols);
  }

  /// Fetches candlestick data for a symbol in given resolution and time range.
  ///
  /// [resolution] examples: "1", "5", "15", "30", "60", "D", "W", "M"
  /// [from] and [to] are Unix timestamps (seconds).
  Future<void> fetchCandles({
    required String symbol,
    required String resolution,
    required int from,
    required int to,
  }) async {
    _candlesLoading = true;
    _candlesErrorMessage = null;
    notifyListeners();

    try {
      final List<CandleData> candles = await _apiService.fetchCandles(
        symbol: symbol,
        resolution: resolution,
        from: from,
        to: to,
      );
      _candlesMap[symbol] = candles;
    } catch (error, stackTrace) {
      _candlesErrorMessage = 'Failed to fetch candles for $symbol: $error';
      debugPrint(_candlesErrorMessage);
      debugPrint('$stackTrace');
      _candlesMap[symbol] = [];
    } finally {
      _candlesLoading = false;
      notifyListeners();
    }
  }

  /// Clears candle data and error message for a symbol.
  void clearCandles(String symbol) {
    _candlesMap.remove(symbol);
    _candlesErrorMessage = null;
    notifyListeners();
  }
}
