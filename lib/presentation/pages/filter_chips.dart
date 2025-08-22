import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A horizontally scrollable list of filter chips with neon gradient styling for selected option.
class FilterChips extends StatefulWidget {
  const FilterChips({super.key});

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  final List<String> options = ['Asia', 'Eropa', 'Amerika', 'Mata Uang'];
  String selectedOption = 'Asia';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final String option = options[index];
          final bool isSelected = option == selectedOption;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedOption = option;
              });
              // TODO: Trigger actual filtering logic in the app/controller
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.deepPurpleAccent : Colors.white24,
                  width: 1.5,
                ),
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
                color: isSelected ? null : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  option,
                  style: GoogleFonts.barlow(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.white70,
                    shadows: isSelected
                        ? const [
                      Shadow(color: Colors.white38, blurRadius: 14),
                    ]
                        : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
