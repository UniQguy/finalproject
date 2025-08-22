import 'package:flutter/material.dart';
import '../models/stock.dart';

/// Manages the user's stock watchlist with add/remove and query capabilities.
class WatchlistProvider with ChangeNotifier {
  final List<Stock> _watchlist = [];

  /// Returns an unmodifiable list of stocks currently in the watchlist.
  List<Stock> get watchlist => List.unmodifiable(_watchlist);

  /// Adds a [stock] to the watchlist if it is not already present.
  void addStock(Stock stock) {
    if (!_watchlist.any((s) => s.symbol == stock.symbol)) {
      _watchlist.add(stock);
      notifyListeners();
    }
  }

  /// Removes a stock from the watchlist by its [symbol].
  void removeStock(String symbol) {
    _watchlist.removeWhere((stock) => stock.symbol == symbol);
    notifyListeners();
  }

  /// Checks whether a stock with the given [symbol] is in the watchlist.
  bool isInWatchlist(String symbol) {
    return _watchlist.any((stock) => stock.symbol == symbol);
  }
}
