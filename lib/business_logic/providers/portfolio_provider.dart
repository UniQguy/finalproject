import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trade_order.dart';
import 'market_provider.dart';
import 'package:finalproject/business_logic/models/stock.dart';

class PortfolioProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  final MarketProvider? marketProvider;

  final Map<String, TradeOrder> _holdings = {};
  final List<TradeOrder> _tradeHistory = [];

  StreamSubscription<QuerySnapshot>? _subscription;

  PortfolioProvider({
    required this.userId,
    required this.marketProvider,
  }) {
    if (userId.isNotEmpty) {
      print('PortfolioProvider: initializing subscription for userId=$userId');
      _subscribeToPortfolio();
    } else {
      print('PortfolioProvider: userId is empty, not subscribing');
    }
  }

  List<TradeOrder> get tradeHistory => List.unmodifiable(_tradeHistory);
  Map<String, TradeOrder> get holdings => Map.unmodifiable(_holdings);
  List<TradeOrder> get currentHoldings => _holdings.values.toList();

  double get portfolioValue {
    if (marketProvider == null) return 0;
    double total = 0;
    _holdings.forEach((symbol, order) {
      final marketStock = marketProvider!.stocks.firstWhere(
            (s) => s.symbol == symbol,
        orElse: () => Stock(
          symbol: symbol,
          company: '',
          price: order.price,
          previousClose: order.price,
          recentPrices: [],
          candles: [],
        ),
      );
      final price = marketStock.price;
      total += price * order.quantity;
    });
    return total;
  }

  TradeOrder? holdingFor(String symbol) {
    return _holdings[symbol];
  }

  Future<void> addOrder(TradeOrder order) async {
    if (userId.isEmpty) {
      print('addOrder: userId empty, aborting');
      return;
    }

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('portfolio')
        .doc();

    await docRef.set(order.toMap());

    _tradeHistory.add(order);

    if (_holdings.containsKey(order.stockSymbol)) {
      final existing = _holdings[order.stockSymbol]!;

      if (order.type == OrderType.call) {
        final int newQty = existing.quantity + order.quantity;
        final double totalCost = (existing.price * existing.quantity) + (order.price * order.quantity);
        final double avgPrice = totalCost / newQty;

        _holdings[order.stockSymbol] = TradeOrder(
          stockSymbol: order.stockSymbol,
          quantity: newQty,
          price: avgPrice,
          type: OrderType.call,
          timestamp: order.timestamp,
        );
      } else {
        final int newQty = existing.quantity - order.quantity;
        if (newQty <= 0) {
          _holdings.remove(order.stockSymbol);
        } else {
          _holdings[order.stockSymbol] = TradeOrder(
            stockSymbol: order.stockSymbol,
            quantity: newQty,
            price: existing.price,
            type: OrderType.call,
            timestamp: order.timestamp,
          );
        }
      }
    } else {
      if (order.quantity > 0) {
        _holdings[order.stockSymbol] = TradeOrder(
          stockSymbol: order.stockSymbol,
          quantity: order.quantity,
          price: order.price,
          type: OrderType.call,
          timestamp: order.timestamp,
        );
      }
    }
    notifyListeners();
  }

  Future<void> sellOrder(String stockSymbol, int quantity, double sellPrice) async {
    if (userId.isEmpty) {
      print('sellOrder: userId empty, aborting');
      return;
    }

    final existing = _holdings[stockSymbol];
    if (existing == null || existing.quantity < quantity) {
      print('sellOrder: insufficient quantity to sell');
      return;
    }

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('portfolio')
        .doc();

    final sellOrder = TradeOrder(
      stockSymbol: stockSymbol,
      quantity: -quantity,
      price: sellPrice,
      type: OrderType.put,
      timestamp: DateTime.now(),
    );

    await docRef.set(sellOrder.toMap());

    final newQty = existing.quantity - quantity;

    if (newQty <= 0) {
      _holdings.remove(stockSymbol);
    } else {
      _holdings[stockSymbol] = TradeOrder(
        stockSymbol: stockSymbol,
        quantity: newQty,
        price: existing.price,
        type: OrderType.call,
        timestamp: DateTime.now(),
      );
    }

    _tradeHistory.add(sellOrder);
    notifyListeners();
  }

  void _subscribeToPortfolio() {
    if (userId.isEmpty) {
      print('subscribeToPortfolio: userId empty, aborting');
      return;
    }

    print('subscribeToPortfolio: subscribing for userId=$userId');
    _subscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('portfolio')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      print('subscribeToPortfolio: snapshot received with ${snapshot.docs.length} docs');

      _holdings.clear();
      _tradeHistory.clear();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('subscribeToPortfolio: doc data: $data');
        final order = TradeOrder.fromMap(data);
        _tradeHistory.add(order);

        if (_holdings.containsKey(order.stockSymbol)) {
          final existing = _holdings[order.stockSymbol]!;
          final int newQty = order.type == OrderType.call
              ? existing.quantity + order.quantity
              : existing.quantity - order.quantity;

          if (newQty <= 0) {
            _holdings.remove(order.stockSymbol);
          } else {
            _holdings[order.stockSymbol] = TradeOrder(
              stockSymbol: order.stockSymbol,
              quantity: newQty,
              price: order.price,
              type: OrderType.call,
              timestamp: order.timestamp,
            );
          }
        } else {
          if (order.quantity > 0) {
            _holdings[order.stockSymbol] = TradeOrder(
              stockSymbol: order.stockSymbol,
              quantity: order.quantity,
              price: order.price,
              type: OrderType.call,
              timestamp: order.timestamp,
            );
          }
        }
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
