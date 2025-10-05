// stock.dart

import 'candle_data.dart';  // if it's in the same folder


class Stock {
  final String symbol;
  final String company;
  double price;
  final double previousClose;
  final List<double> recentPrices;

  /// New field for OHLC candlestick data
  final List<CandleData> candles;

  Stock({
    required this.symbol,
    required this.company,
    required this.price,
    required this.previousClose,
    required this.recentPrices,
    this.candles = const [],
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
      candles: (json['candles'] as List<dynamic>?)
          ?.map((e) => CandleData(
        date: DateTime.parse(e['date']),
        open: (e['open'] as num).toDouble(),
        high: (e['high'] as num).toDouble(),
        low: (e['low'] as num).toDouble(),
        close: (e['close'] as num).toDouble(),
        volume: (e['volume'] as num).toDouble(),
      ))
          .toList() ?? <CandleData>[],
    );
  }

  /// Converts this [Stock] instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'company': company,
    'price': price,
    'previousClose': previousClose,
    'recentPrices': recentPrices,
    'candles': candles
        .map((c) => {
      'date': c.date.toIso8601String(),
      'open': c.open,
      'high': c.high,
      'low': c.low,
      'close': c.close,
      'volume': c.volume,
    })
        .toList(),
  };

  /// Returns a copy of this [Stock] with optionally updated fields.
  Stock copyWith({
    String? symbol,
    String? company,
    double? price,
    double? previousClose,
    List<double>? recentPrices,
    List<CandleData>? candles,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      company: company ?? this.company,
      price: price ?? this.price,
      previousClose: previousClose ?? this.previousClose,
      recentPrices: recentPrices ?? this.recentPrices,
      candles: candles ?? this.candles,
    );
  }

  @override
  String toString() {
    return 'Stock(symbol: $symbol, company: $company, price: $price, previousClose: $previousClose, recentPrices: $recentPrices, candles: $candles)';
  }

  // Used for DropdownButton equality.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Stock &&
              runtimeType == other.runtimeType &&
              symbol == other.symbol;

  @override
  int get hashCode => symbol.hashCode;
}

