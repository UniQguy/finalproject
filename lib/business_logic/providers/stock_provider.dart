import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/api_service.dart';

/// Provides stock data fetching and state management.
class StockProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService(apiKey: 'd2jhgg9r01qj8a5jdo1gd2jhgg9r01qj8a5jdo20');

  List<Stock> _stocks = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Returns an unmodifiable list of fetched stocks.
  List<Stock> get stocks => List.unmodifiable(_stocks);

  /// Indicates whether a fetch operation is in progress.
  bool get isLoading => _isLoading;

  /// Stores last error message encountered during fetch, if any.
  String? get errorMessage => _errorMessage;

  /// Fetches the latest stock data for the specified symbols from the API.
  /// Updates internal state and notifies listeners appropriately.
  Future<void> fetchStocks(List<String> symbols) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedStocks = await _apiService.fetchStocks(symbols);
      _stocks = fetchedStocks;
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      debugPrint('Error fetching stocks: $e');
      debugPrint('$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
