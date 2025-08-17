import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/animated_gradient_widget.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/animated_in_view.dart';
import '../../business_logic/providers/theme_provider.dart';

class NewsDetailPage extends StatelessWidget {
  final String title;
  final String summary;
  final String time;
  final String? imageUrl; // Optional: pass an image URL if available
  final String? fullArticle; // Optional: full text if available

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.summary,
    required this.time,
    this.imageUrl,
    this.fullArticle,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientWidget(),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 4),

                // Headline
                GradientText(
                  text: title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                  gradient: LinearGradient(
                    colors: [themeProvider.primaryColor, themeProvider.lossColor],
                  ),
                ),
                const SizedBox(height: 10),

                // Time
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 20),

                // Optional image
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  AnimatedInView(
                    index: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 200,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              color: themeProvider.primaryColor,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.white10,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white38,
                              size: 48,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Summary
                AnimatedInView(
                  index: 1,
                  child: AppGlassyCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: themeProvider
                        .primaryColor, // ✅ Added required borderColor
                    child: Text(
                      summary,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Full Article if provided
                if (fullArticle != null && fullArticle!.trim().isNotEmpty)
                  AnimatedInView(
                    index: 2,
                    child: AppGlassyCard(
                      padding: const EdgeInsets.all(16),
                      borderColor: themeProvider
                          .primaryColor, // ✅ Added required borderColor
                      child: Text(
                        fullArticle!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
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
