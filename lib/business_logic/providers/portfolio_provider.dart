import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/trade_order.dart';

class PortfolioProvider extends ChangeNotifier {
  static const _kHoldingsKey = 'portfolio_holdings';

  /// Current open holdings
  final Map<String, TradeOrder> _holdings = {};

  /// Closed trades history (with realised P/L)
  final List<TradeOrder> _tradeHistory = [];

  Map<String, TradeOrder> get holdings => Map.unmodifiable(_holdings);
  List<TradeOrder> get tradeHistory => List.unmodifiable(_tradeHistory);

  PortfolioProvider() {
    _loadFromPrefs();
  }

  /// Add new or update existing open trade
  void addOrder(TradeOrder order) {
    if (_holdings.containsKey(order.stockSymbol)) {
      final existing = _holdings[order.stockSymbol]!;
      final newQuantity = existing.quantity + order.quantity;
      final newPrice = ((existing.price * existing.quantity) +
          (order.price * order.quantity)) /
          newQuantity;

      _holdings[order.stockSymbol] = TradeOrder(
        stockSymbol: order.stockSymbol,
        type: order.type,
        price: newPrice,
        quantity: newQuantity,
        timestamp: DateTime.now(),
      );
    } else {
      _holdings[order.stockSymbol] = order;
    }
    _saveToPrefs();
    notifyListeners();
  }

  /// Remove holding entirely — without history
  void removeOrder(String symbol) {
    _holdings.remove(symbol);
    _saveToPrefs();
    notifyListeners();
  }

  /// Fully close a holding and add to history with P/L
  void closeTrade(String symbol, {required double sellPrice}) {
    if (_holdings.containsKey(symbol)) {
      final existingOrder = _holdings[symbol]!;

      final pl = (sellPrice - existingOrder.price) *
          existingOrder.quantity;

      _tradeHistory.add(TradeOrder(
        stockSymbol: existingOrder.stockSymbol,
        type: existingOrder.type,
        price: existingOrder.price,
        quantity: existingOrder.quantity,
        timestamp: existingOrder.timestamp,
        closePrice: sellPrice,
        profitLoss: pl,
      ));

      _holdings.remove(symbol);
      _saveToPrefs();
      notifyListeners();
    }
  }

  /// Partial or full sell with accurate realised P/L
  void sellOrder(String symbol, int quantityToSell,
      {required double sellPrice}) {
    if (!_holdings.containsKey(symbol)) return;
    final existingOrder = _holdings[symbol]!;

    // This sell’s P/L
    final plPerShare = sellPrice - existingOrder.price;
    final totalPL = plPerShare * quantityToSell;

    // Record sold batch into history
    _tradeHistory.add(TradeOrder(
      stockSymbol: existingOrder.stockSymbol,
      type: existingOrder.type,
      price: existingOrder.price,
      quantity: quantityToSell,
      timestamp: existingOrder.timestamp,
      closePrice: sellPrice,
      profitLoss: totalPL,
    ));

    if (quantityToSell >= existingOrder.quantity) {
      // Fully closed
      _holdings.remove(symbol);
    } else {
      // Update holding with reduced quantity
      _holdings[symbol] = TradeOrder(
        stockSymbol: existingOrder.stockSymbol,
        type: existingOrder.type,
        price: existingOrder.price,
        quantity: existingOrder.quantity - quantityToSell,
        timestamp: existingOrder.timestamp,
      );
    }

    _saveToPrefs();
    notifyListeners();
  }

  /// Clear closed trade history (does not affect holdings)
  void clearHistory() {
    _tradeHistory.clear();
    notifyListeners();
  }

  /// Remove all holdings and clear persistence
  Future<void> clearAllHoldings() async {
    _holdings.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHoldingsKey);
    notifyListeners();
  }

  /// Calculate portfolio value based on buy prices
  double get portfolioValue {
    double total = 0;
    for (final order in _holdings.values) {
      total += order.price * order.quantity;
    }
    return total;
  }

  /// Load holdings from persistent storage
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_kHoldingsKey);

    if (jsonString != null) {
      final jsonList = json.decode(jsonString) as List;
      _holdings.clear();
      for (var item in jsonList) {
        final order = TradeOrder.fromJson(item);
        _holdings[order.stockSymbol] = order;
      }
      notifyListeners();
    }
  }

  /// Save holdings to persistent storage
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
    _holdings.values.map((o) => o.toJson()).toList();
    await prefs.setString(_kHoldingsKey, json.encode(jsonList));
  }
}
