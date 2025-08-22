import 'package:flutter/material.dart';
import '../widgets/market_movers_widget.dart';

/// Page displaying the market movers using the MarketMoversWidget.
class MarketMoversPage extends StatelessWidget {
  const MarketMoversPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Movers'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MarketMoversWidget(scale: scale),
      ),
    );
  }
}
