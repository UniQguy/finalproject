import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final List<bool> _expanded = List.filled(6, false);

  final List<Map<String, String>> _sections = [
    {
      'title': 'Stock Market Basics',
      'text': 'Learn what stocks and markets are, how they operate, and key terms like market cap, dividends, indexes.',
      'image': 'lib/assets/images/stock_market_basics.png',
    },
    {
      'title': 'Trading Fundamentals',
      'text': 'Understand buying/selling, order types, portfolio building, and trade execution processes.',
      'image': 'lib/assets/images/trading_fundamentals.png',
    },
    {
      'title': 'Market Analysis',
      'text': 'Introduction to technical and fundamental analysis, including candlestick charts and indicators.',
      'image': 'lib/assets/images/market_analysis.png',
    },
    {
      'title': 'Risk Management',
      'text': 'Learn risk concepts, diversification, stop-loss orders, and position sizing.',
      'image': 'lib/assets/images/risk_management.png',
    },
    {
      'title': 'Getting Started',
      'text': 'How to research stocks, read analysis, and start investing or trading responsibly.',
      'image': 'lib/assets/images/getting_started.png',
    },
    {
      'title': 'Useful Resources',
      'text': 'Links to Investopedia, financial news sites, tutorials, and stock market glossaries.',
      'image': 'lib/assets/images/useful_resources.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final primaryColor = Colors.deepPurpleAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Stock Market'),
        backgroundColor: primaryColor,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _sections.length,
          itemBuilder: (context, index) {
            final section = _sections[index];
            final isExpanded = _expanded[index];
            return Card(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 6,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _expanded[index] = !isExpanded;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              section['title']!,
                              style: GoogleFonts.barlow(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: primaryColor),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(section['image']!, height: 180, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          section['text']!,
                          style: TextStyle(fontSize: 16, height: 1.5, color: textColor),
                        ),
                        const SizedBox(height: 8),
                      ],
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
