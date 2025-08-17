import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/market_provider.dart';

class StockTicker extends StatefulWidget {
  const StockTicker({super.key});

  @override
  State<StockTicker> createState() => _StockTickerState();
}

class _StockTickerState extends State<StockTicker> {
  late ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    const double scrollSpeed = 65; // pixels per second
    const int refreshRateMs = 16;
    final double scrollAmountPerTick = scrollSpeed * refreshRateMs / 1000;

    _timer = Timer.periodic(Duration(milliseconds: refreshRateMs), (timer) {
      if (!_scrollController.hasClients) return;

      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.offset;
      double nextScroll = currentScroll + scrollAmountPerTick;

      if (nextScroll >= maxScroll) {
        // Loop back to start smoothly
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(nextScroll);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stocks = context.watch<MarketProvider>().stocks;

    return SizedBox(
      height: 36,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stocks.length * 2, // duplicate items for smooth loop
        itemBuilder: (context, index) {
          final stock = stocks[index % stocks.length];
          return _StockTickerItem(stock: stock);
        },
      ),
    );
  }
}

class _StockTickerItem extends StatefulWidget {
  final dynamic stock;

  const _StockTickerItem({required this.stock});

  @override
  State<_StockTickerItem> createState() => _StockTickerItemState();
}

class _StockTickerItemState extends State<_StockTickerItem> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Color?> _colorAnimation;
  late double _oldPrice;

  @override
  void initState() {
    super.initState();
    _oldPrice = widget.stock.price;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _initAnimation();
  }

  void _initAnimation() {
    _colorAnimation = ColorTween(
      begin: widget.stock.isUp ? Colors.greenAccent : Colors.redAccent,
      end: Colors.white,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant _StockTickerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stock.price != _oldPrice) {
      _animController.reset();
      _initAnimation();
      _oldPrice = widget.stock.price;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  widget.stock.symbol,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.purpleAccent.shade100,
                    shadows: const [
                      Shadow(
                        color: Colors.deepPurple,
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '₹${widget.stock.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _colorAnimation.value,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  widget.stock.isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: widget.stock.isUp ? Colors.greenAccent : Colors.redAccent,
                  size: 20,
                ),
              ],
            ),
          );
        });
  }
}
