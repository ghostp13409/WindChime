import 'package:flutter/material.dart';
import 'package:windchime/models/quote/quote.dart';
import 'package:windchime/services/quote_service.dart';

class WelcomePopup extends StatelessWidget {
  final VoidCallback onEnterApp;

  const WelcomePopup({
    super.key,
    required this.onEnterApp,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).colorScheme.background.withOpacity(0.95),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Welcome Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome to WindChime',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your journey to mindfulness begins here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.withOpacity(0.8),
                            letterSpacing: 0.2,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quote Section
              FutureBuilder<Quote>(
                future: QuoteService.getQuoteOfTheDay(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading your daily inspiration...',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.red.withOpacity(0.1)
                            : Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Unable to load today\'s quote',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'But your mindfulness journey can still begin!',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.withOpacity(0.7),
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final quote = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF8E97FD).withOpacity(0.1)
                          : const Color(0xFF8E97FD).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8E97FD).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.format_quote,
                              color: const Color(0xFF8E97FD),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Today\'s Inspiration',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: const Color(0xFF8E97FD),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '"${quote.text}"',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    height: 1.5,
                                    letterSpacing: 0.3,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '— ${quote.author}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Enter App Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onEnterApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor:
                        Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Enter WindChime',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip button (subtle)
              TextButton(
                onPressed: onEnterApp,
                child: Text(
                  'Skip',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.withOpacity(0.6),
                        letterSpacing: 0.3,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
