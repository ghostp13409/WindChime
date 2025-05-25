import 'package:flutter/material.dart';
import 'package:windchime/models/quote/quote.dart';
import 'package:windchime/services/quote_service.dart';

class QuoteOfDay extends StatelessWidget {
  const QuoteOfDay({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Quote>(
      future: QuoteService.getQuoteOfTheDay(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF8E97FD).withOpacity(0.2)
                  : const Color(0xFF8E97FD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF8E97FD),
                width: 1,
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          print('Quote error: ${snapshot.error}');
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF8E97FD).withOpacity(0.2)
                  : const Color(0xFF8E97FD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.red,
                width: 1,
              ),
            ),
            child: Text(
              'Failed to load quote',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF2D3142),
                fontSize: 16,
              ),
            ),
          );
        }

        final quote = snapshot.data!;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF8E97FD).withOpacity(0.2)
                : const Color(0xFF8E97FD).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF8E97FD),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quote of the Day',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : const Color(0xFF2D3142),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '"${quote.text}"',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF2D3142).withOpacity(0.9),
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '- ${quote.author}',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : const Color(0xFF2D3142).withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
