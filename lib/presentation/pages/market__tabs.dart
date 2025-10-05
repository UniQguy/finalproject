import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A horizontally scrollable list of market category tabs with glassmorphic style and dynamic gradient selection.
class MarketTabs extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const MarketTabs({Key? key, this.onTabChanged}) : super(key: key);

  @override
  State<MarketTabs> createState() => _MarketTabsState();
}

class _MarketTabsState extends State<MarketTabs> {
  final List<String> tabs = ['Global', 'Crypto', 'Reksadana', 'CFD'];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final bool isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              if (widget.onTabChanged != null) {
                widget.onTabChanged!(index);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [
                    Color(0xFF833AB4),
                    Color(0xFFF77737),
                    Color(0xFFE1306C),
                    Color(0xFFC13584),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white24,
                  width: 1.8,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
                    : null,
              ),
              child: Text(
                tabs[index],
                style: GoogleFonts.barlow(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: isSelected ? Colors.white : Colors.white70,
                  shadows: isSelected
                      ? const [
                    Shadow(
                      color: Colors.white54,
                      blurRadius: 16,
                      offset: Offset(0, 0),
                    ),
                  ]
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
