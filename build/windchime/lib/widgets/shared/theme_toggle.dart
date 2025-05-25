import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:windchime/providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return GestureDetector(
          onTap: () => themeProvider.toggleTheme(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                themeProvider.isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
