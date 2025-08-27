import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompactNewsSection extends StatelessWidget {
  final double scale;

  const CompactNewsSection({Key? key, required this.scale}) : super(key: key);

  static final List<Map<String, String>> newsList = [
    {
      'title': 'Tech Stocks Surge Amid Market Optimism',
      'summary': 'Leading tech companies see significant gains as market confidence grows.',
      'imageUrl': 'https://images.unsplash.com/photo-1460925895917-afdab827c52e?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Oil Prices Hit New Highs',
      'summary': 'Global oil prices have risen due to supply concerns.',
      'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834bfb?auto=format&fit=crop&w=800&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (newsList.isEmpty) {
      return Center(
        child: Text(
          'No news available',
          style: TextStyle(color: Colors.white54, fontSize: 16 * scale),
        ),
      );
    }

    return SizedBox(
      height: 220 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12 * scale),
        itemCount: newsList.length,
        separatorBuilder: (_, __) => SizedBox(width: 16 * scale),
        itemBuilder: (context, index) {
          final news = newsList[index];
          return Container(
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
                  if (news['imageUrl'] != null && news['imageUrl']!.isNotEmpty)
                    SizedBox(
                      height: 120 * scale,
                      width: double.infinity,
                      child: Image.network(
                        news['imageUrl']!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
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
                    ),
                  Padding(
                    padding: EdgeInsets.all(16 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news['title'] ?? '',
                          style: GoogleFonts.barlow(
                            fontSize: 17 * scale,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.6),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          news['summary'] ?? '',
                          style: GoogleFonts.barlow(
                            fontSize: 14 * scale,
                            color: Colors.white70,
                            height: 1.4,
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
          );
        },
      ),
    );
  }
}
