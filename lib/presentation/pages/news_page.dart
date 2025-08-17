import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/animated_gradient_widget.dart';
import '../widgets/animated_in_view.dart';
import '../widgets/app_glassy_card.dart';
import '../widgets/gradient_text.dart';
import '../../business_logic/providers/theme_provider.dart';
import 'news_detail_page.dart'; // ✅ Import the details page

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    // Example news data — replace with your provider/API data
    final newsArticles = List.generate(
      8,
          (i) => {
        'title': 'Breaking News Headline #$i',
        'summary': 'This is a short description of the breaking news article number $i.',
        'time': '${i + 1}h ago',
        'imageUrl': '', // Or provide a valid thumbnail URL
        'fullText':
        'This is the full article content for Breaking News Headline #$i. '
            'You can replace this text with the actual news content loaded from your API.'
      },
    );

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientWidget(),
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // Page Header
                GradientText(
                  text: '📰 Latest News',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                  gradient: LinearGradient(
                    colors: [themeProvider.primaryColor, themeProvider.lossColor],
                  ),
                ),
                const SizedBox(height: 20),

                // News list
                ...newsArticles.asMap().entries.map(
                      (entry) {
                    final index = entry.key;
                    final article = entry.value;

                    return AnimatedInView(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: GestureDetector(
                          onTap: () {
                            // ✅ Navigate to NewsDetailPage with passed data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NewsDetailPage(
                                  title: article['title']!,
                                  summary: article['summary']!,
                                  time: article['time']!,
                                  imageUrl: article['imageUrl']!,
                                  fullArticle: article['fullText']!,
                                ),
                              ),
                            );
                          },
                          child: AppGlassyCard(
                            borderColor: themeProvider
                                .primaryColor, // ✅ required parameter added
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail placeholder (replace with Image.network for real thumbnails)
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        themeProvider.primaryColor,
                                        themeProvider.lossColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.article,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // News content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article['title']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        article['summary']!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        article['time']!,
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
