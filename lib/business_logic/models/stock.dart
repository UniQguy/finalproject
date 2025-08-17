class Stock {
  final String symbol;
  final String name;
  final String? description;
  double price;
  double previousClose;
  bool isUp;
  List<double> recentPrices;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.previousClose,
    this.description,
  })  : isUp = price >= previousClose,
        recentPrices = [price];

  /// Updates the stock's current price and keeps track of recent prices
  void updatePrice(double newPrice) {
    isUp = newPrice >= price;
    price = newPrice;
    recentPrices.add(newPrice);

    // Limit history to last 30 values for performance/sparklines
    if (recentPrices.length > 30) {
      recentPrices.removeAt(0);
    }
  }
}
