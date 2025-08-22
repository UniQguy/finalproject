import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompactNewsSection extends StatelessWidget {
  final double scale;

  const CompactNewsSection({Key? key, required this.scale}) : super(key: key);

  static final List<Map<String, String>> newsList = [
    {
      'title': 'Tech Stocks Surge Amid Market Optimism',
      'summary': 'Leading tech companies see significant gains as market confidence grows.',
      'imageUrl': 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=800&q=80',
    },
    {
      'title': 'Oil Prices Hit New Highs',
      'summary': 'Global oil prices have risen due to supply concerns.',
      // FIXED URL:
      'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
    },
    // Add more items as desired
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
        padding: EdgeInsets.symmetric(horizontal: 8 * scale),
        itemCount: newsList.length,
        separatorBuilder: (_, __) => SizedBox(width: 12 * scale),
        itemBuilder: (context, index) {
          final news = newsList[index];
          return Container(
            width: 280 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18 * scale),
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade900, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (news['imageUrl'] != null)
                    SizedBox(
                      height: 120 * scale,
                      width: double.infinity,
                      child: Image.network(
                        news['imageUrl']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade700,
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white24,
                              size: 40 * scale,
                            ),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(12 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news['title'] ?? '',
                          style: GoogleFonts.barlow(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6 * scale),
                        Text(
                          news['summary'] ?? '',
                          style: GoogleFonts.barlow(
                            fontSize: 13 * scale,
                            color: Colors.white70,
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
