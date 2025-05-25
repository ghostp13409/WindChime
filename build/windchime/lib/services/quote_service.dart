import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prog2435_final_project_app/models/quote/quote.dart';

class QuoteService {
  // ZenQuotes API endpoint for quote of the day
  static const String _apiUrl = 'https://zenquotes.io/api/today';
  static const String _cacheKey = 'cached_quote';
  static const String _lastFetchDateKey = 'last_fetch_date';

  static Future<Quote> getQuoteOfTheDay() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? lastFetchDate = prefs.getString(_lastFetchDateKey);
      final String currentDate = DateTime.now().toIso8601String().split('T')[0];

      // Check if we already fetched a quote today
      if (lastFetchDate == currentDate) {
        final String? cachedQuoteStr = prefs.getString(_cacheKey);
        if (cachedQuoteStr != null) {
          return Quote.fromJson(jsonDecode(cachedQuoteStr));
        }
      }

      // Fetch new quote from API
      final response = await http.get(Uri.parse(_apiUrl));

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed data: $data');

        if (data.isNotEmpty) {
          final Map<String, dynamic> quoteData = data[0];
          // ZenQuotes uses 'q' for quote text and 'a' for author
          final Quote quote = Quote(
            text: quoteData['q'] as String,
            author: quoteData['a'] as String,
          );
          print('Created quote: $quote');

          // Cache the new quote
          await prefs.setString(
              _cacheKey,
              jsonEncode({
                'q': quote.text,
                'a': quote.author,
              }));
          await prefs.setString(_lastFetchDateKey, currentDate);

          return quote;
        }
      }

      print('API Error: Status ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to load quote: ${response.statusCode}');
    } catch (e, stackTrace) {
      print('Error fetching quote: $e\n$stackTrace');

      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? cachedQuoteStr = prefs.getString(_cacheKey);
        if (cachedQuoteStr != null) {
          return Quote.fromJson(jsonDecode(cachedQuoteStr));
        }
      } catch (e) {
        print('Error reading cache: $e');
      }

      // Fallback quote if both API and cache fail
      return const Quote(
        text: 'Peace comes from within. Do not seek it without.',
        author: 'Buddha',
      );
    }
  }
}
