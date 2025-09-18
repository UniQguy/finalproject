import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/api_service.dart';

/// Provides stock data fetching and state management with Finnhub API integration.
class StockProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Stock> _stocks = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Constructor accepting an API key to initialize the ApiService.
  StockProvider({required String apiKey}) : _apiService = ApiService(apiKey: apiKey);

  /// Returns an unmodifiable list of the latest fetched stocks.
  List<Stock> get stocks => List.unmodifiable(_stocks);

  /// Is stock data currently being fetched.
  bool get isLoading => _isLoading;

  /// Stores any error message from the last fetch attempt.
  String? get errorMessage => _errorMessage;

  /// Fetches stock data for the given list of symbols from the API.
  /// On success, updates the internal stocks list and notifies listeners.
  /// On failure, populates the errorMessage and notifies listeners.
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

  /// Convenience method to start fetching and keep it simple to call.
  void startFetchingStocks(List<String> symbols) {
    fetchStocks(symbols);
  }
}
