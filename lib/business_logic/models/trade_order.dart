/// Enum representing types of trade orders.
enum OrderType { call, put }

/// Model class representing a trade order with stock symbol, type, price, quantity, and timestamp.
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

  /// Creates a [TradeOrder] from a JSON map.
  factory TradeOrder.fromJson(Map<String, dynamic> json) {
    return TradeOrder(
      stockSymbol: json['stockSymbol'] as String,
      type: _orderTypeFromString(json['type'] as String),
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts this [TradeOrder] to a JSON map.
  Map<String, dynamic> toJson() => {
    'stockSymbol': stockSymbol,
    'type': type.name,
    'price': price,
    'quantity': quantity,
    'timestamp': timestamp.toIso8601String(),
  };

  /// Helper method to convert string to [OrderType] enum.
  static OrderType _orderTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'call':
        return OrderType.call;
      case 'put':
        return OrderType.put;
      default:
        throw ArgumentError('Unknown OrderType: $type');
    }
  }

  /// Returns a readable string representation useful for debugging.
  @override
  String toString() {
    return 'TradeOrder(stockSymbol: $stockSymbol, type: $type, price: $price, quantity: $quantity, timestamp: $timestamp)';
  }
}
