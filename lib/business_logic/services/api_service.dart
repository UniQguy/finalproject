import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';

/// A service class that interacts with the Finnhub API to fetch stock data.
class ApiService {
  final String apiKey;
  static const String baseUrl = 'https://finnhub.io/api/v1';

  ApiService({required this.apiKey});

  /// Fetches real-time stock quote for a single [symbol].
  ///
  /// Returns a [Stock] object with latest price and previous close.
  /// Throws an [Exception] if fetching fails or returns empty.
  Future<Stock> fetchStockQuote(String symbol) async {
    final url = Uri.parse('$baseUrl/quote?symbol=$symbol&token=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data.isEmpty) {
        throw Exception('No data available for symbol: $symbol');
      }

      return Stock(
        symbol: symbol,
        company: '', // Company name can be fetched separately if needed
        price: (data['c'] as num).toDouble(),
        previousClose: data['pc'] != null ? (data['pc'] as num).toDouble() : 0.0,
        recentPrices: const [],
      );
    } else {
      throw Exception('Failed to load stock quote for $symbol: HTTP ${response.statusCode}');
    }
  }

  /// Fetches stock quotes for multiple [symbols].
  ///
  /// Ignores individual fetch failures and continues.
  /// Returns list of successfully fetched [Stock] objects.
  Future<List<Stock>> fetchStocks(List<String> symbols) async {
    List<Stock> stocks = [];
    for (var symbol in symbols) {
      try {
        final stock = await fetchStockQuote(symbol);
        stocks.add(stock);
      } catch (e) {
        // Individual errors ignored; could be logged here
      }
    }
    return stocks;
  }

  /// Fetches company profile information for the given [symbol].
  ///
  /// Returns a [Stock] instance with the company name populated.
  /// Throws an [Exception] if fetching fails.
  Future<Stock> fetchCompanyProfile(String symbol) async {
    final url = Uri.parse('$baseUrl/stock/profile2?symbol=$symbol&token=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Stock(
        symbol: symbol,
        company: data['name'] ?? '',
        price: 0.0,
        previousClose: 0.0,
        recentPrices: const [],
      );
    } else {
      throw Exception('Failed to load company profile for $symbol: HTTP ${response.statusCode}');
    }
  }
}
