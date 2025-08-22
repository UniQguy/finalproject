import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

/// Detailed page showing full news article with title, time, and image.
class NewsDetailPage extends StatelessWidget {
  final String title;
  final String summary;
  final String time;
  final String imageUrl;
  final String fullArticle;

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.summary,
    required this.time,
    required this.imageUrl,
    required this.fullArticle,
  });

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.of(context).size.width / 900;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'News Detail',
          style: GoogleFonts.barlow(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22 * scale,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // Back to homepage
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(18 * scale),
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20 * scale),
              child: Image.network(
                imageUrl,
                height: 220 * scale,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 220 * scale,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220 * scale,
                  color: Colors.white12,
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white24,
                    size: 48 * scale,
                  ),
                ),
              ),
            ),
          SizedBox(height: 24 * scale),
          Text(
            title,
            style: GoogleFonts.barlow(
              fontWeight: FontWeight.bold,
              fontSize: 24 * scale,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            time,
            style: GoogleFonts.barlow(
              fontSize: 12 * scale,
              color: Colors.purpleAccent,
            ),
          ),
          SizedBox(height: 24 * scale),
          Text(
            fullArticle,
            style: GoogleFonts.barlow(
              fontSize: 16 * scale,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
