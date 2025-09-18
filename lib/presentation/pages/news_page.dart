import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class NewsArticle {
  final String headline;
  final String summary;
  final String imageUrl;
  final String url;
  final int? datetime;

  NewsArticle({
    required this.headline,
    required this.summary,
    required this.imageUrl,
    required this.url,
    this.datetime,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      headline: json['headline'] ?? 'No title',
      summary: json['summary'] ?? '',
      imageUrl: json['image'] ?? '',
      url: json['url'] ?? '',
      datetime: json['datetime'] is int ? json['datetime'] : null,
    );
  }
}

class NewsPage extends StatefulWidget {
  final String apiKey;

  const NewsPage({Key? key, required this.apiKey}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsArticle> newsArticles = [];
  bool isLoading = true;
  bool isError = false;

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

    final Uri uri = Uri.parse(
      'https://finnhub.io/api/v1/news?category=general&token=${widget.apiKey}',
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final body = response.body.trim();
        // Defensive: only parse non-empty, non-null, non-error responses
        if (body.isNotEmpty) {
          final List<dynamic>? data = jsonDecode(body) is List ? jsonDecode(body) : null;
          if (data != null && data.isNotEmpty) {
            final articles = data
                .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
                .where((article) =>
            article.imageUrl.isNotEmpty &&
                Uri.tryParse(article.imageUrl) != null &&
                article.headline.isNotEmpty &&
                article.url.isNotEmpty)
                .toList();
            setState(() {
              newsArticles = articles;
              isLoading = false;
            });
            return;
          }
        }
        // Response body is empty or not an array
        setState(() {
          newsArticles = [];
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the article URL')),
      );
    }
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 1) return '${diff.inDays} days ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inHours >= 1) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 1) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 900.0;

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
      body: Builder(builder: (context) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
        }

        if (isError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load news.',
                  style: TextStyle(color: Colors.white54, fontSize: 16 * scale),
                ),
                SizedBox(height: 12 * scale),
                ElevatedButton(
                  onPressed: fetchNews,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(fontSize: 16 * scale),
                  ),
                ),
              ],
            ),
          );
        }

        // Defensive: handle empty articles after fetch
        if (newsArticles.isEmpty) {
          return Center(
            child: Text(
              'No valid news articles available.',
              style: TextStyle(color: Colors.white54, fontSize: 16 * scale),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: fetchNews,
          color: Colors.purpleAccent,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 22 * scale),
            scrollDirection: Axis.horizontal,
            itemCount: newsArticles.length,
            separatorBuilder: (_, __) => SizedBox(width: 18 * scale),
            itemBuilder: (context, index) {
              final article = newsArticles[index];
              return GestureDetector(
                onTap: () => _openUrl(article.url),
                child: Container(
                  width: 280 * scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24 * scale),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3F1B8A), Colors.black87],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.shade900.withOpacity(0.6),
                        offset: Offset(0, 6 * scale),
                        blurRadius: 16 * scale,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24 * scale)),
                          child: Image.network(
                            article.imageUrl,
                            width: double.infinity,
                            height: 110 * scale,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 110 * scale,
                                  color: Colors.grey.shade800,
                                  child: Icon(Icons.broken_image,
                                      color: Colors.white24, size: 40 * scale),
                                ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.all(13 * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.headline,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.barlow(
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * scale,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 7 * scale),
                            Text(
                              article.summary,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.barlow(
                                fontSize: 13 * scale,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 13 * scale), // Spacing for visual separation
                            Text(
                              _formatTimestamp(article.datetime),
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
        );
      }),
    );
  }
}
