import 'package:flutter/material.dart';
import '../widgets/app_glassy_card.dart';
import 'stock_comparison_section.dart';

class StockComparisonPage extends StatelessWidget {
  const StockComparisonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Stock Comparison'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StockComparisonSection(scale: 1.0),
      ),
    );
  }
}
