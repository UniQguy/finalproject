import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Model representing a single news article.
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
      datetime: json['datetime'],
    );
  }
}

/// NewsProvider fetches and manages live news data from API.
class NewsProvider extends ChangeNotifier {
  final String apiKey;

  NewsProvider({required this.apiKey});

  List<NewsArticle> _newsList = [];
  bool _isLoading = false;
  bool _isError = false;

  List<NewsArticle> get newsList => _newsList;
  bool get isLoading => _isLoading;
  bool get isError => _isError;

  /// Fetches news articles asynchronously from Finnhub API.
  Future<void> fetchNews() async {
    _isLoading = true;
    _isError = false;
    notifyListeners();

    final Uri uri = Uri.parse(
      'https://finnhub.io/api/v1/news?category=general&token=$apiKey',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _newsList = data
            .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
            .where(
              (article) =>
          article.imageUrl.isNotEmpty && Uri.tryParse(article.imageUrl) != null,
        )
            .toList();
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        _isError = true;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _isError = true;
      notifyListeners();
    }
  }
}
