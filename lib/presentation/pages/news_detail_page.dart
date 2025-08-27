import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class NewsDetailPage extends StatelessWidget {
  final String title;
  final String time;
  final String imageUrl;
  final String fullArticle;
  final String summary;

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.time,
    required this.imageUrl,
    required this.fullArticle,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 900;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(onPressed: () => context.go('/home')),
        title: Text(
          'News Detail',
          style: GoogleFonts.barlow(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22 * scale,
          ),
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
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            time,
            style: GoogleFonts.barlow(
              color: Colors.purpleAccent,
              fontWeight: FontWeight.w600,
              fontSize: 12 * scale,
            ),
          ),
          SizedBox(height: 24 * scale),
          Text(
            fullArticle,
            style: GoogleFonts.barlow(
              fontSize: 16 * scale,
              height: 1.5,
              color: Colors.white70,
            ),
          ),
          if (summary.isNotEmpty) ...[
            SizedBox(height: 24 * scale),
            Text(
              'Summary',
              style: GoogleFonts.barlow(
                fontSize: 16 * scale,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              summary,
              style: GoogleFonts.barlow(
                fontSize: 14 * scale,
                color: Colors.white60,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
