import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../business_logic/providers/market_provider.dart';

class CompactWatchlistSection extends StatelessWidget {
  final double scale;

  const CompactWatchlistSection({Key? key, required this.scale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();

    final watchlist = marketProvider.stocks.take(4).toList();

    if (watchlist.isEmpty) {
      return Center(
        child: Text(
          'No stocks in your watchlist',
          style: TextStyle(color: Colors.white54, fontSize: 16 * scale),
        ),
      );
    }

    return SizedBox(
      height: 240 * scale, // Fixed height to prevent overflow
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 8 * scale),
        itemCount: watchlist.length,
        separatorBuilder: (_, __) => Divider(color: Colors.white24),
        itemBuilder: (context, index) {
          final stock = watchlist[index];
          return ListTile(
            title: Text(
              stock.symbol,
              style: GoogleFonts.barlow(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16 * scale,
              ),
            ),
            subtitle: Text(
              stock.company,
              style: GoogleFonts.barlow(
                color: Colors.white70,
                fontSize: 14 * scale,
              ),
            ),
            trailing: Text(
              '₹${stock.price.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16 * scale,
              ),
            ),
            onTap: () {
              // TODO: Implement watchlist stock tap handler, e.g. navigate to stock detail
            },
            contentPadding: EdgeInsets.symmetric(vertical: 4 * scale, horizontal: 8 * scale),
            dense: true,
            horizontalTitleGap: 12 * scale,
          );
        },
      ),
    );
  }
}
