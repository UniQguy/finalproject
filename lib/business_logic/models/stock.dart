class Stock {
  final String symbol;
  final String company;
  double price;
  final double previousClose;
  final List<double> recentPrices;

  Stock({
    required this.symbol,
    required this.company,
    required this.price,
    required this.previousClose,
    required this.recentPrices,
  });

  /// Creates a [Stock] instance from a JSON map.
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] as String,
      company: json['company'] as String,
      price: (json['price'] as num).toDouble(),
      previousClose: (json['previousClose'] as num?)?.toDouble() ?? 0,
      recentPrices: (json['recentPrices'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ??
          <double>[],
    );
  }

  /// Converts this [Stock] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'company': company,
    'price': price,
    'previousClose': previousClose,
    'recentPrices': recentPrices,
  };

  /// Returns a copy of this [Stock] with optionally updated fields.
  Stock copyWith({
    String? symbol,
    String? company,
    double? price,
    double? previousClose,
    List<double>? recentPrices,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      company: company ?? this.company,
      price: price ?? this.price,
      previousClose: previousClose ?? this.previousClose,
      recentPrices: recentPrices ?? this.recentPrices,
    );
  }

  @override
  String toString() {
    return 'Stock(symbol: $symbol, company: $company, price: $price, previousClose: $previousClose, recentPrices: $recentPrices)';
  }

  // Add these to fix DropdownButton equality issue:

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Stock &&
              runtimeType == other.runtimeType &&
              symbol == other.symbol;

  @override
  int get hashCode => symbol.hashCode;
}
