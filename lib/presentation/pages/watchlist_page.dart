import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../business_logic/providers/watchlist_provider.dart';
import '../../business_logic/providers/market_provider.dart';
import '../../business_logic/models/stock.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/animated_in_view.dart';

enum SortOption { symbolAsc, symbolDesc, priceAsc, priceDesc }

class WatchlistPage extends StatefulWidget {
  final double scale;

  const WatchlistPage({Key? key, required this.scale}) : super(key: key);

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Stock> _filteredStocks = [];
  SortOption _sortOption = SortOption.symbolAsc;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStocks);
    // Simulate loading delay for shimmer effect
    Future.delayed(const Duration(seconds: 2), () => setState(() => _isLoading = false));
  }

  void _filterStocks() {
    final query = _searchController.text.toLowerCase();
    final marketStocks = context.read<MarketProvider>().stocks;

    setState(() {
      if (query.isEmpty) {
        _filteredStocks = [];
      } else {
        _filteredStocks = marketStocks
            .where((stock) =>
        stock.symbol.toLowerCase().contains(query) ||
            stock.company.toLowerCase().contains(query))
            .toList();
        _filteredStocks = _sortStocks(_filteredStocks);
      }
    });
  }

  List<Stock> _sortStocks(List<Stock> stocks) {
    List<Stock> sorted = List.from(stocks);
    switch (_sortOption) {
      case SortOption.symbolAsc:
        sorted.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
      case SortOption.symbolDesc:
        sorted.sort((a, b) => b.symbol.compareTo(a.symbol));
        break;
      case SortOption.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
    return sorted;
  }

  void _addToWatchlist(Stock stock) {
    context.read<WatchlistProvider>().addStock(stock);
    _searchController.clear();
    setState(() {
      _filteredStocks.clear();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStocks);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final watchlist = context.watch<WatchlistProvider>().watchlist;
    final marketProvider = context.read<MarketProvider>();
    final sortedWatchlist = _sortStocks(watchlist);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Manage Watchlist',
          style: GoogleFonts.barlow(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22 * scale,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56 * scale),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white, fontSize: 16 * scale),
                    cursorColor: Colors.purpleAccent,
                    decoration: InputDecoration(
                      hintText: 'Search stocks to add...',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      prefixIcon: Icon(Icons.search, color: Colors.purpleAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12 * scale,
                        horizontal: 20 * scale,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<SortOption>(
                  dropdownColor: Colors.deepPurple.shade900,
                  value: _sortOption,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortOption = value;
                        if (_filteredStocks.isNotEmpty) {
                          _filteredStocks = _sortStocks(_filteredStocks);
                        }
                      });
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: SortOption.symbolAsc,
                      child: Text('Symbol ↑', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: SortOption.symbolDesc,
                      child: Text('Symbol ↓', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: SortOption.priceAsc,
                      child: Text('Price ↑', style: TextStyle(color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: SortOption.priceDesc,
                      child: Text('Price ↓', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  iconEnabledColor: Colors.purpleAccent,
                  underline: Container(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: _isLoading
            ? Column(
          children: List.generate(
            5,
                (index) => Padding(
              padding: EdgeInsets.symmetric(vertical: 12 * scale),
              child: Shimmer(
                duration: const Duration(seconds: 2),
                color: Colors.white24,
                child: Container(
                  height: 60 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16 * scale),
                  ),
                ),
              ),
            ),
          ),
        )
            : _filteredStocks.isNotEmpty
            ? ListView.separated(
          itemCount: _filteredStocks.length,
          separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final stock = _filteredStocks[index];
            final alreadyInWatchlist = context.watch<WatchlistProvider>().isInWatchlist(stock.symbol);

            return AnimatedInView(
              index: index,
              child: AppGlassyCard(
                borderRadius: BorderRadius.circular(16 * scale),
                padding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 16 * scale),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.symbol,
                            style: TextStyle(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            stock.company,
                            style: TextStyle(
                              fontSize: 14 * scale,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${stock.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * scale,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        alreadyInWatchlist ? Icons.check_circle : Icons.add_circle,
                        color: alreadyInWatchlist ? Colors.greenAccent : Colors.purpleAccent,
                        size: 28 * scale,
                      ),
                      onPressed: alreadyInWatchlist ? null : () => _addToWatchlist(stock),
                    ),
                  ],
                ),
              ),
            );
          },
        )
            : sortedWatchlist.isEmpty
            ? Center(
          child: Text(
            'Your watchlist is empty.\nSearch and add stocks to watch.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 18 * scale),
          ),
        )
            : ListView.separated(
          itemCount: sortedWatchlist.length,
          separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
          itemBuilder: (context, index) {
            final stock = sortedWatchlist[index];
            final price = marketProvider.stocks.firstWhere(
                  (s) => s.symbol == stock.symbol,
              orElse: () => stock,
            ).price;

            return Dismissible(
              key: Key(stock.symbol),
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20 * scale),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                context.read<WatchlistProvider>().removeStock(stock.symbol);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${stock.symbol} removed from watchlist')),
                );
              },
              child: AnimatedInView(
                index: index,
                child: AppGlassyCard(
                  borderRadius: BorderRadius.circular(16 * scale),
                  padding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 16 * scale),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stock.symbol,
                              style: TextStyle(
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              stock.company,
                              style: TextStyle(
                                fontSize: 14 * scale,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16 * scale,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle,
                          color: Colors.redAccent,
                          size: 28 * scale,
                        ),
                        onPressed: () {
                          context.read<WatchlistProvider>().removeStock(stock.symbol);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${stock.symbol} removed from watchlist')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
