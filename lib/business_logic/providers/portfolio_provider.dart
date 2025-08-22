import 'package:flutter/material.dart';
import '../models/trade_order.dart';

/// Manages the user's portfolio holdings and trade history.
class PortfolioProvider extends ChangeNotifier {
  // Maps stock symbol to latest aggregated TradeOrder representing current holdings.
  final Map<String, TradeOrder> _holdings = {};

  // Complete list of all executed trade orders, in chronological order.
  final List<TradeOrder> _tradeHistory = [];

  /// Read-only access to chronological past trade orders.
  List<TradeOrder> get tradeHistory => List.unmodifiable(_tradeHistory);

  /// Read-only snapshot of current holdings as a map: stockSymbol -> aggregated TradeOrder.
  Map<String, TradeOrder> get holdings => Map.unmodifiable(_holdings);

  /// Computes total portfolio value as the sum of (price * quantity) of all holdings.
  double get portfolioValue {
    double total = 0;
    _holdings.forEach((_, order) {
      total += order.price * order.quantity;
    });
    return total;
  }

  /// Adds a new trade order to the history and updates holdings accordingly.
  ///
  /// This method currently aggregates quantities for simplicity.
  /// For more complex scenarios, incorporate buy/sell logic.
  void addOrder(TradeOrder order) {
    _tradeHistory.add(order);

    if (_holdings.containsKey(order.stockSymbol)) {
      final existing = _holdings[order.stockSymbol]!;

      // Aggregate quantity - expand per your trade logic.
      final newQuantity = existing.quantity + order.quantity;

      _holdings[order.stockSymbol] = TradeOrder(
        stockSymbol: order.stockSymbol,
        quantity: newQuantity,
        price: order.price,
        type: order.type,
        timestamp: order.timestamp,
      );
    } else {
      _holdings[order.stockSymbol] = order;
    }
    notifyListeners();
  }

  /// Removes a holding by its stock symbol.
  void removeHolding(String stockSymbol) {
    if (_holdings.containsKey(stockSymbol)) {
      _holdings.remove(stockSymbol);
      notifyListeners();
    }
  }

  /// Clears all holdings and trade history.
  void clearPortfolio() {
    _holdings.clear();
    _tradeHistory.clear();
    notifyListeners();
  }
}
