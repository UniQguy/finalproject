enum OrderType { put, call }

class TradeOrder {
  final String stockSymbol;
  final OrderType type;
  final double price; // Buy price
  final int quantity;
  final DateTime timestamp;

  // Optional: set when trade is closed or partially sold
  final double? closePrice;  // Sell price
  final double? profitLoss;  // Realised P/L (positive or negative)

  TradeOrder({
    required this.stockSymbol,
    required this.type,
    required this.price,
    required this.quantity,
    required this.timestamp,
    this.closePrice,
    this.profitLoss,
  });

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
    'stockSymbol': stockSymbol,
    'type': type.name,
    'price': price,
    'quantity': quantity,
    'timestamp': timestamp.toIso8601String(),
    'closePrice': closePrice,
    'profitLoss': profitLoss,
  };

  /// Create TradeOrder from JSON
  factory TradeOrder.fromJson(Map<String, dynamic> json) {
    return TradeOrder(
      stockSymbol: json['stockSymbol'] as String,
      type: OrderType.values.firstWhere(
            (e) => e.name == (json['type'] ?? 'call'),
        orElse: () => OrderType.call,
      ),
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      closePrice: json['closePrice'] != null
          ? (json['closePrice'] as num).toDouble()
          : null,
      profitLoss: json['profitLoss'] != null
          ? (json['profitLoss'] as num).toDouble()
          : null,
    );
  }
}
