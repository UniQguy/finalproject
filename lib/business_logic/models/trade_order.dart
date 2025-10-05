import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderType { call, put }

class TradeOrder {
  final String stockSymbol;
  final OrderType type;
  final double price;
  final int quantity;
  final DateTime timestamp;

  TradeOrder({
    required this.stockSymbol,
    required this.type,
    required this.price,
    required this.quantity,
    required this.timestamp,
  });

  factory TradeOrder.fromJson(Map<String, dynamic> json) {
    return TradeOrder(
      stockSymbol: json['stockSymbol'] as String,
      type: _stringToOrderType(json['type'] as String),
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stockSymbol': stockSymbol,
      'type': type.name,
      'price': price,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Converts to Firestore map (timestamp field as DateTime)
  Map<String, dynamic> toMap() {
    return {
      'stockSymbol': stockSymbol,
      'type': type.name,
      'price': price,
      'quantity': quantity,
      'timestamp': timestamp,
    };
  }

  // Creates object from Firestore document map with safe Timestamp conversion
  factory TradeOrder.fromMap(Map<String, dynamic> map) {
    var ts = map['timestamp'];
    DateTime dateTime;

    if (ts is Timestamp) {
      dateTime = ts.toDate();
    } else if (ts is DateTime) {
      dateTime = ts;
    } else if (ts is String) {
      dateTime = DateTime.parse(ts);
    } else {
      throw ArgumentError('Cannot parse timestamp: $ts');
    }

    return TradeOrder(
      stockSymbol: map['stockSymbol'] as String,
      type: _stringToOrderType(map['type'] as String),
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      timestamp: dateTime,
    );
  }

  static OrderType _stringToOrderType(String type) {
    switch (type.toLowerCase()) {
      case 'call':
        return OrderType.call;
      case 'put':
        return OrderType.put;
      default:
        throw ArgumentError('Unknown OrderType: $type');
    }
  }

  @override
  String toString() {
    return 'TradeOrder(stockSymbol: $stockSymbol, type: $type, price: $price, quantity: $quantity, timestamp: $timestamp)';
  }
}
