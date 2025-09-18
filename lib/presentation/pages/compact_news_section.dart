import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompactNewsSection extends StatelessWidget {
  final double scale;
  final List<Map<String, String>> newsList;
  final void Function(Map<String, String> news)? onNewsTap;

  const CompactNewsSection({
    Key? key,
    required this.scale,
    required this.newsList,
    this.onNewsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (newsList.isEmpty) {
      return Center(
        child: Text(
          'No news available',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16 * scale,
          ),
        ),
      );
    }

    return SizedBox(
      height: 240 * scale, // Increased height to fit all text
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12 * scale),
        itemCount: newsList.length,
        separatorBuilder: (_, __) => SizedBox(width: 16 * scale),
        itemBuilder: (context, index) {
          final news = newsList[index];
          final imageUrl = news['imageUrl'] ?? '';
          return GestureDetector(
            onTap: () {
              if (onNewsTap != null) onNewsTap!(news);
            },
            child: Container(
              width: 280 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20 * scale),
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade900, Colors.black87],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 104 * scale, // Slightly reduced image height
                      width: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? Semantics(
                        label: news['title'] ?? 'News image',
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.purpleAccent,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade800,
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white24,
                              size: 40 * scale,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        color: Colors.grey.shade900,
                        child: Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.grey.shade700,
                            size: 40 * scale,
                          ),
                        ),
                      ),
                    ),
                    // Content with reduced top/bottom padding
                    Padding(
                      padding: EdgeInsets.fromLTRB(14 * scale, 10 * scale, 14 * scale, 10 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news['title'] ?? '',
                            style: GoogleFonts.barlow(
                              fontSize: 16 * scale, // Reduced font size
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.6),
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6 * scale),
                          Text(
                            news['summary'] ?? '',
                            style: GoogleFonts.barlow(
                              fontSize: 13 * scale, // Reduced font size
                              color: Colors.white70,
                              height: 1.35,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
