import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> newsArticles = [];
  bool isLoading = true;
  bool isError = false;

  final String apiKey = 'YOUR_API_KEY_HERE'; // Replace with actual API key

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final Uri uri = Uri.parse('https://finnhub.io/api/v1/news?category=general&token=$apiKey');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        newsArticles = data.where((article) {
          final image = article['image'];
          return image != null && image.toString().isNotEmpty && Uri.tryParse(image) != null;
        }).toList();
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _openUrl(String? url) async {
    if (url == null) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 1) return '${diff.inDays} days ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inHours >= 1) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 1) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 900;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: BackButton(onPressed: () => context.go('/home')),
          title: Text(
            'Market News',
            style: GoogleFonts.barlow(
              color: Colors.purpleAccent,
              fontSize: 22 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
      );
    }

    if (isError || newsArticles.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: BackButton(onPressed: () => context.go('/home')),
          title: Text(
            'Market News',
            style: GoogleFonts.barlow(
              color: Colors.purpleAccent,
              fontSize: 22 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'Failed to load news or no valid articles.',
            style: TextStyle(color: Colors.white54, fontSize: 16 * scale),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(onPressed: () => context.go('/home')),
        title: Text(
          'Market News',
          style: GoogleFonts.barlow(
            color: Colors.purpleAccent,
            fontSize: 22 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchNews,
        child: SizedBox(
          height: 250 * scale,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 18),
            scrollDirection: Axis.horizontal,
            itemCount: newsArticles.length,
            separatorBuilder: (_, __) => SizedBox(width: 16 * scale),
            itemBuilder: (context, index) {
              final article = newsArticles[index];
              return GestureDetector(
                onTap: () => _openUrl(article['url'] as String?),
                child: Container(
                  width: 300 * scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20 * scale),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3F1B8A), Colors.black87],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.shade900.withOpacity(0.7),
                        offset: Offset(0, 6),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article['image'] != null && article['image'].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
                          child: Image.network(
                            article['image'],
                            width: double.infinity,
                            height: 110 * scale,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 110 * scale,
                              color: Colors.grey.shade800,
                              child: Icon(Icons.broken_image, color: Colors.white24, size: 40),
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.all(12 * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article['headline'] ?? 'No title',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.barlow(
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * scale,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6 * scale),
                            Text(
                              article['summary'] ?? '',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.barlow(
                                fontSize: 13 * scale,
                                color: Colors.white70,
                              ),
                            ),
                            Spacer(),
                            Text(
                              _formatTimestamp(article['datetime']),
                              style: GoogleFonts.barlow(
                                fontSize: 11 * scale,
                                color: Colors.white38,
                              ),
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
        ),
      ),
    );
  }
}
