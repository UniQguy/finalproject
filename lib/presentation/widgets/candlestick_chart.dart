import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:provider/provider.dart';

import '../../business_logic/providers/stock_provider.dart';

class CandlestickChartWidget extends StatefulWidget {
  final String stockSymbol;

  const CandlestickChartWidget({Key? key, required this.stockSymbol}) : super(key: key);

  @override
  State<CandlestickChartWidget> createState() => _CandlestickChartWidgetState();
}

class _CandlestickChartWidgetState extends State<CandlestickChartWidget> {
  bool isLoading = true;
  String? errorMessage;
  String selectedPeriod = '1D';

  final Map<String, String> periodToResolution = {
    '1D': 'D',
    '5D': 'D',
    '1M': 'D',
    '6M': 'W',
    'YTD': 'M',
    '1Y': 'W',
    '5Y': 'M',
    'MAX': 'M',
  };

  @override
  void initState() {
    super.initState();
    _fetchCandles();
  }

  Future<void> _fetchCandles() async {
    final stockProvider = context.read<StockProvider>();

    final now = DateTime.now();
    int days = 30;

    switch (selectedPeriod) {
      case '1D':
        days = 1;
        break;
      case '5D':
        days = 5;
        break;
      case '1M':
        days = 30;
        break;
      case '6M':
        days = 180;
        break;
      case 'YTD':
        days = now.difference(DateTime(now.year)).inDays;
        break;
      case '1Y':
        days = 365;
        break;
      case '5Y':
        days = 365 * 5;
        break;
      case 'MAX':
        days = 365 * 10;
        break;
    }

    final to = now.millisecondsSinceEpoch ~/ 1000;
    final from = now.subtract(Duration(days: days)).millisecondsSinceEpoch ~/ 1000;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await stockProvider.fetchCandles(
        symbol: widget.stockSymbol,
        resolution: periodToResolution[selectedPeriod] ?? 'D',
        from: from,
        to: to,
      );
      if (!mounted) return;

      final candles = stockProvider.getCandles(widget.stockSymbol);
      if (candles.isEmpty) {
        setState(() {
          errorMessage = "No candle data available.";
          isLoading = false;
        });
        return;
      }
      setState(() {
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Error fetching candle data: $e";
        isLoading = false;
      });
    }
  }

  void _onPeriodSelected(String period) {
    setState(() {
      selectedPeriod = period;
    });
    _fetchCandles();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF071A3F), Color(0xFF203663)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Consumer<StockProvider>(
        builder: (context, stockProvider, child) {
          final candlesData = stockProvider.getCandles(widget.stockSymbol);

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (errorMessage != null) {
            return Center(child: Text(errorMessage!));
          } else if (candlesData.isEmpty) {
            return const Center(child: Text("No candle data available"));
          } else {
            final List<Candle> candles = candlesData.map((candleData) {
              return Candle(
                date: candleData.date,
                open: candleData.open,
                high: candleData.high,
                low: candleData.low,
                close: candleData.close,
                volume: candleData.volume,
              );
            }).toList();

            return Column(
              children: [
                Expanded(
                  child: Candlesticks(
                    candles: candles,
                    onLoadMoreCandles: () {
                      // Optionally fetch more data for infinite scrolling
                      return Future.value();
                    },
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  children: ['1D', '5D', '1M', '6M', 'YTD', '1Y', '5Y', 'MAX']
                      .map((period) => _PeriodButton(
                    label: period,
                    isSelected: period == selectedPeriod,
                    onTap: () => _onPeriodSelected(period),
                  ))
                      .toList(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepPurpleAccent : Colors.white12,
        foregroundColor: isSelected ? Colors.white : Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}
