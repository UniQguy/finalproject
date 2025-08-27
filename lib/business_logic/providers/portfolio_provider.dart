import 'package:flutter/foundation.dart';
import '../models/trade_order.dart';

/// Manages the user's portfolio holdings and trade history.
class PortfolioProvider extends ChangeNotifier {
  /// Maps stock symbol to latest aggregated TradeOrder representing current holdings.
  final Map<String, TradeOrder> _holdings = {};

  /// Complete list of all executed trade orders, in chronological order.
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
  /// This method supports simple aggregation: buy adds quantity, sell subtracts quantity.
  /// Holdings with zero or negative quantity are removed.
  void addOrder(TradeOrder order) {
    // Add to trade history list
    _tradeHistory.add(order);

    // Get current holding quantity
    final existing = _holdings[order.stockSymbol];
    int newQuantity = order.type == OrderType.call
        ? (existing?.quantity ?? 0) + order.quantity
        : (existing?.quantity ?? 0) - order.quantity;

    // Remove holding if quantity zero or negative
    if (newQuantity <= 0) {
      _holdings.remove(order.stockSymbol);
    } else {
      // Update holdings map with new aggregate order
      _holdings[order.stockSymbol] = TradeOrder(
        stockSymbol: order.stockSymbol,
        quantity: newQuantity,
        price: order.price, // Optionally improve with average price computation
        type: OrderType.call, // Holdings type is call by default as positive quantity means owned shares
        timestamp: order.timestamp,
      );
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
