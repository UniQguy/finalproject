import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';

/// A searchable page for stocks with animated results and neon UI styling.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';

  // Sample stock data
  final List<Map<String, dynamic>> allStocks = [
    {'symbol': 'AAPL', 'name': 'Apple Inc.', 'price': 153.21},
    {'symbol': 'TSLA', 'name': 'Tesla, Inc.', 'price': 710.55},
    {'symbol': 'MSFT', 'name': 'Microsoft Corporation', 'price': 299.95},
    {'symbol': 'GOOGL', 'name': 'Alphabet Inc.', 'price': 2703.44},
    {'symbol': 'AMZN', 'name': 'Amazon.com, Inc.', 'price': 3349.20},
  ];

  List<Map<String, dynamic>> get filteredStocks {
    if (query.isEmpty) return [];
    return allStocks.where((stock) {
      final lowerQuery = query.toLowerCase();
      return stock['symbol'].toLowerCase().contains(lowerQuery) ||
          stock['name'].toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / 900;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // Back to homepage
        ),
        title: TextField(
          style: TextStyle(color: Colors.white, fontSize: 18 * scale),
          cursorColor: Colors.purpleAccent,
          decoration: InputDecoration(
            hintText: 'Search stocks...',
            hintStyle: TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white10,
            prefixIcon: Icon(Icons.search, color: Colors.purpleAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 14 * scale,
              horizontal: 20 * scale,
            ),
          ),
          onChanged: (val) => setState(() => query = val),
          autofocus: true,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(18 * scale),
        children: filteredStocks.asMap().entries.map((entry) {
          final index = entry.key;
          final stock = entry.value;
          return AnimatedInView(
            index: index,
            child: AppGlassyCard(
              borderRadius: BorderRadius.circular(20 * scale),
              padding: EdgeInsets.all(18 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock['symbol'],
                        style: GoogleFonts.barlow(
                          fontWeight: FontWeight.bold,
                          fontSize: 18 * scale,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Text(
                        stock['name'],
                        style: GoogleFonts.barlow(
                          fontSize: 14 * scale,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹${stock['price'].toStringAsFixed(2)}',
                    style: GoogleFonts.barlow(
                      fontWeight: FontWeight.w700,
                      fontSize: 16 * scale,
                      color: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
