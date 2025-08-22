import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/providers/watchlist_provider.dart';

class Watchlist extends StatefulWidget {
  final double scale;
  const Watchlist({Key? key, required this.scale}) : super(key: key);

  @override
  State<Watchlist> createState() => _WatchlistState();
}

class _WatchlistState extends State<Watchlist> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final watchlist = context.watch<WatchlistProvider>().watchlist;
    final marketProvider = context.watch<MarketProvider>();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            if (watchlist.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40 * scale),
                child: Text(
                  'Your watchlist is empty. Add some stocks!',
                  style: TextStyle(color: Colors.white54, fontSize: 18 * scale),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...watchlist.map((stock) {
                final marketStock = marketProvider.stocks.firstWhere(
                      (s) => s.symbol == stock.symbol,
                  orElse: () => stock,
                );
                final price = marketStock.price;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12 * scale),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24 * scale,
                        backgroundColor: Colors.deepPurple.shade600,
                        child: Text(
                          stock.symbol.length > 2
                              ? stock.symbol.substring(0, 2).toUpperCase()
                              : stock.symbol.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18 * scale,
                          ),
                        ),
                      ),
                      SizedBox(width: 20 * scale),
                      Expanded(
                        child: Text(
                          stock.symbol,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20 * scale,
                          ),
                        ),
                      ),
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18 * scale,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.greenAccent.withOpacity(0.7),
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
