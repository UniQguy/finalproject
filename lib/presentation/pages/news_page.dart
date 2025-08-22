import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> newsArticles = [];
  bool isLoading = true;
  bool isError = false;

  final String apiKey = 'd2jhgg9r01qj8a5jdo1gd2jhgg9r01qj8a5jdo20';

  @override
  void initState() {
    super.initState();
    fetchStockNews();
  }

  Future<void> fetchStockNews() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final Uri uri = Uri.parse(
      'https://finnhub.io/api/v1/news?category=general&token=$apiKey',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Filter to only articles with valid image URLs
        newsArticles = data.where((article) =>
        article['image'] != null &&
            article['image'].toString().isNotEmpty &&
            Uri.tryParse(article['image']) != null
        ).toList();
        setState(() {
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

  Future<void> _openUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 900;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Market News',
            style: GoogleFonts.barlow(
              color: Colors.purpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 22 * scale,
              letterSpacing: 1.2,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.purpleAccent),
        ),
      );
    }

    if (isError || newsArticles.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Market News',
            style: GoogleFonts.barlow(
              color: Colors.purpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 22 * scale,
              letterSpacing: 1.2,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
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
        title: Text(
          'Market News',
          style: GoogleFonts.barlow(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22 * scale,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchStockNews,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18 * scale),
          child: SizedBox(
            height: 250 * scale,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16 * scale),
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
                          offset: const Offset(0, 6),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
                          child: Image.network(
                            article['image'],
                            width: double.infinity,
                            height: 110 * scale,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                'https://via.placeholder.com/300x110/3F1B8A/FFFFFF?text=No+Image',
                                width: double.infinity,
                                height: 110 * scale,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(12 * scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article['headline'] ?? 'No title',
                                  style: GoogleFonts.barlow(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16 * scale,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6 * scale),
                                Text(
                                  article['summary'] ?? '',
                                  style: GoogleFonts.barlow(
                                    fontSize: 13 * scale,
                                    color: Colors.white70,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
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
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 1) return '${diff.inDays} days ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inHours >= 1) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 1) return '${diff.inMinutes} minutes ago';
    return 'Just now';
  }
}
