import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/animated_gradient_widget.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/models/stock.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();

    final List<Stock> results = query.isEmpty
        ? []
        : market.stocks
        .where((stock) =>
    stock.symbol.toLowerCase().contains(query.toLowerCase()) ||
        stock.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientWidget(),
          SafeArea(
            child: Column(
              children: [
                // ░░ Header ░░
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: GradientText(
                          text: '🔍 Search Stocks',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w900),
                          gradient: const LinearGradient(
                            colors: [Colors.tealAccent, Colors.purpleAccent],
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                        const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // ░░ Search field (glassy) ░░
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppGlassyCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    borderRadius: BorderRadius.circular(14),
                    borderColor: Colors.tealAccent,
                    child: TextField(
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Type stock symbol or name...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        icon:
                        Icon(Icons.search, color: Colors.tealAccent),
                      ),
                      onChanged: (val) => setState(() => query = val),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ░░ Results list ░░
                Expanded(
                  child: results.isEmpty
                      ? const Center(
                    child: Text(
                      "No results yet. Start typing to search.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                      : ListView.builder(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final stock = results[index];
                      final bool isUp =
                          stock.price >= stock.previousClose;

                      return AnimatedInView(
                        index: index,
                        child: Padding(
                          padding:
                          const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              /// 👇 Return the selected stock to the previous page
                              Navigator.pop(context, stock);
                            },
                            child: AppGlassyCard(
                              padding: const EdgeInsets.all(14),
                              borderColor: isUp
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stock.symbol,
                                          style: TextStyle(
                                            color: isUp
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          stock.name,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${stock.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${isUp ? '+' : ''}${(stock.price - stock.previousClose).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: isUp
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
