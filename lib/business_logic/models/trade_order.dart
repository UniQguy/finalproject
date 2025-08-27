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
