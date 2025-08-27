import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/market_movers_widget.dart';
import '../widgets/animated_realtime_chart.dart';
import '../../business_logic/providers/market_provider.dart';

class MarketMoversPage extends StatefulWidget {
  const MarketMoversPage({Key? key}) : super(key: key);

  @override
  _MarketMoversPageState createState() => _MarketMoversPageState();
}

class _MarketMoversPageState extends State<MarketMoversPage> {
  String? selectedStockSymbol;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final marketProvider = context.read<MarketProvider>();
    selectedStockSymbol ??= marketProvider.stocks.isNotEmpty ? marketProvider.stocks.first.symbol : null;
  }

  void _handleStockChanged(String newSymbol) {
    setState(() {
      selectedStockSymbol = newSymbol;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Colors.deepPurpleAccent;
    final scale = MediaQuery.of(context).size.width / 900;
    final marketProvider = context.watch<MarketProvider>();

    if (marketProvider.stocks.isEmpty || selectedStockSymbol == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Market Movers'),
          backgroundColor: Colors.black,
          foregroundColor: accentColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Movers'),
        backgroundColor: Colors.black,
        foregroundColor: accentColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          children: [
            MarketMoversWidget(scale: scale),
            SizedBox(height: 32 * scale),
            // Pass selectedSymbol and onChanged callback for controlled stock selection
            AnimatedRealtimeChartWithSelector(
              key: ValueKey(selectedStockSymbol),
              accentColor: accentColor,
              selectedSymbol: selectedStockSymbol!,
              stockSymbols: marketProvider.stocks.map((s) => s.symbol).toList(),
              onSymbolChanged: _handleStockChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// New Widget wrapping AnimatedRealtimeChart plus external stock selector
class AnimatedRealtimeChartWithSelector extends StatefulWidget {
  final Color accentColor;
  final String selectedSymbol;
  final List<String> stockSymbols;
  final ValueChanged<String> onSymbolChanged;

  const AnimatedRealtimeChartWithSelector({
    Key? key,
    required this.accentColor,
    required this.selectedSymbol,
    required this.stockSymbols,
    required this.onSymbolChanged,
  }) : super(key: key);

  @override
  _AnimatedRealtimeChartWithSelectorState createState() => _AnimatedRealtimeChartWithSelectorState();
}

class _AnimatedRealtimeChartWithSelectorState extends State<AnimatedRealtimeChartWithSelector> {
  late String currentSymbol;

  @override
  void initState() {
    super.initState();
    currentSymbol = widget.selectedSymbol;
  }

  @override
  void didUpdateWidget(covariant AnimatedRealtimeChartWithSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSymbol != widget.selectedSymbol) {
      setState(() {
        currentSymbol = widget.selectedSymbol;
      });
    }
  }

  void _onChanged(String? newVal) {
    if (newVal != null) {
      setState(() {
        currentSymbol = newVal;
      });
      widget.onSymbolChanged(newVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Select Stock",
            labelStyle: TextStyle(color: widget.accentColor, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.accentColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.accentColor, width: 2)),
          ),
          dropdownColor: Colors.grey.shade900,
          value: currentSymbol,
          items: widget.stockSymbols.map((symbol) {
            return DropdownMenuItem(
              value: symbol,
              child: Text(symbol, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: _onChanged,
        ),
        Expanded(
          child: AnimatedRealtimeChart(
            key: ValueKey(currentSymbol),
            accentColor: widget.accentColor,
            initialSymbol: currentSymbol,
          ),
        ),
      ],
    );
  }
}

// Edit AnimatedRealtimeChart to accept initialSymbol param:
// class AnimatedRealtimeChart extends StatefulWidget {
//   final Color accentColor;
//   final String initialSymbol;
//   // ...
// }
