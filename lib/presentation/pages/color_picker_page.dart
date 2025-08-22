import 'package:flutter/material.dart';
import '../widgets/animated_gradient_widget.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/animated_in_view.dart';

/// A page displaying a palette of accent colors allowing the user to pick one.
class ColorPickerPage extends StatelessWidget {
  final ValueChanged<Color> onColorSelected;
  final Color currentColor;

  const ColorPickerPage({
    super.key,
    required this.onColorSelected,
    required this.currentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Curated palette of vibrant neon accent colors
    final List<Color> colors = [
      Colors.tealAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.blueAccent,
      Colors.amberAccent,
      Colors.greenAccent,
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.cyanAccent,
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Animated neon background gradient for lively visual appeal
          const AnimatedGradientWidget(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: GradientText(
                    text: '🎨 Pick Accent Color',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    gradient: const LinearGradient(
                      colors: [Colors.purpleAccent, Colors.tealAccent],
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: colors.length,
                    itemBuilder: (context, index) {
                      final color = colors[index];
                      final bool isSelected = color == currentColor;

                      return AnimatedInView(
                        index: index,
                        child: GestureDetector(
                          onTap: () {
                            onColorSelected(color);
                            Navigator.pop(context);
                          },
                          child: AppGlassyCard(
                            borderRadius: BorderRadius.circular(50),
                            padding: EdgeInsets.zero,
                            borderColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.6),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
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
