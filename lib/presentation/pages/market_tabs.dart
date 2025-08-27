import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketTabs extends StatefulWidget {
  final ValueChanged<int>? onTabChanged;

  const MarketTabs({super.key, this.onTabChanged});

  @override
  State<MarketTabs> createState() => _MarketTabsState();
}

class _MarketTabsState extends State<MarketTabs> with SingleTickerProviderStateMixin {
  final List<String> tabs = ['Global', 'Crypto', 'Reksadana', 'CFD'];
  int selectedIndex = 0;

  void _handleTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onTabChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: SizedBox(
        key: ValueKey<int>(selectedIndex),
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final bool isSelected = index == selectedIndex;
            return GestureDetector(
              onTap: () => _handleTap(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
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
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.white24,
                    width: 1.7,
                  ),
                  color: isSelected ? null : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: GoogleFonts.barlow(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? Colors.white : Colors.white70,
                      shadows: isSelected
                          ? const [
                        Shadow(
                          color: Colors.white38,
                          blurRadius: 14,
                        ),
                      ]
                          : null,
                    ),
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
