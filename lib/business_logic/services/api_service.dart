import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock.dart';
import '../models/candle_data.dart';  // Import CandleData model here

/// A service class that interacts with the Finnhub API to fetch stock data.
class ApiService {
  final String apiKey;
  static const String baseUrl = 'https://finnhub.io/api/v1';

  ApiService({required this.apiKey});

  /// Fetches real-time stock quote for a single [symbol].
  /// Returns a [Stock] object with latest price and previous close.
  /// Throws an [Exception] if fetching fails or returns empty.
  Future<Stock> fetchStockQuote(String symbol) async {
    final url = Uri.parse('$baseUrl/quote?symbol=$symbol&token=$apiKey');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.isEmpty || data['c'] == null) {
          throw Exception('No quote data available for symbol: $symbol');
        }

        return Stock(
          symbol: symbol,
          company: '', // Company name can be fetched separately if needed
          price: (data['c'] as num).toDouble(),
          previousClose: data['pc'] != null ? (data['pc'] as num).toDouble() : 0.0,
          recentPrices: const [],
        );
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid API key.');
      } else {
        throw Exception('Failed to load stock quote for $symbol: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network or parsing error while fetching stock quote for $symbol: $e');
    }
  }

  /// Fetches stock quotes for multiple [symbols] in parallel.
  /// Returns list of successfully fetched [Stock] objects.
  Future<List<Stock>> fetchStocks(List<String> symbols) async {
    final futures = symbols.map((symbol) =>
        fetchStockQuote(symbol).catchError((e) {
          // Can log errors here.
          return null;
        })
    );

    final results = await Future.wait(futures);
    return results.whereType<Stock>().toList();
  }

  /// Fetches company profile information for given [symbol].
  /// Returns a [Stock] instance with company name populated.
  Future<Stock> fetchCompanyProfile(String symbol) async {
    final url = Uri.parse('$baseUrl/stock/profile2?symbol=$symbol&token=$apiKey');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Stock(
          symbol: symbol,
          company: data['name'] ?? '',
          price: 0.0,
          previousClose: 0.0,
          recentPrices: const [],
          // Additional fields can be added here if Stock model supports.
        );
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid API key.');
      } else {
        throw Exception('Failed to load company profile for $symbol: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network or parsing error while fetching company profile for $symbol: $e');
    }
  }

  /// Fetches OHLC candlestick data for the [symbol] between [from] and [to] Unix timestamps (seconds).
  /// The [resolution] parameter is the granularity of the candles (e.g. 1,5,15,30,60,D,W,M).
  /// Returns a list of [CandleData].
  Future<List<CandleData>> fetchCandles({
    required String symbol,
    required String resolution,
    required int from,
    required int to,
  }) async {
    final url = Uri.parse('$baseUrl/stock/candle?symbol=$symbol&resolution=$resolution&from=$from&to=$to&token=$apiKey');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['s'] != 'ok' || data['c'] == null) {
          throw Exception('No candle data available for symbol: $symbol');
        }

        final List<dynamic> time = data['t'] ?? [];
        final List<dynamic> open = data['o'] ?? [];
        final List<dynamic> high = data['h'] ?? [];
        final List<dynamic> low = data['l'] ?? [];
        final List<dynamic> close = data['c'] ?? [];
        final List<dynamic> volume = data['v'] ?? [];

        List<CandleData> candles = [];

        for (int i = 0; i < time.length; i++) {
          candles.add(CandleData(
            date: DateTime.fromMillisecondsSinceEpoch(time[i] * 1000),
            open: (open[i] as num).toDouble(),
            high: (high[i] as num).toDouble(),
            low: (low[i] as num).toDouble(),
            close: (close[i] as num).toDouble(),
            volume: (volume[i] as num).toDouble(),
          ));
        }

        return candles;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid API key.');
      } else {
        throw Exception('Failed to load candles for $symbol: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network or parsing error while fetching candles for $symbol: $e');
    }
  }
}
