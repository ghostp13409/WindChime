/*
 * Copyright (C) 2025 Parth Gajjar
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windchime/models/meditation/breathing_pattern.dart';
import 'package:windchime/models/meditation/meditation.dart';
import 'package:windchime/screens/home/home_screen.dart';
import 'package:windchime/screens/home/redesigned_home_screen.dart';
import 'package:windchime/screens/meditation/home_screen.dart';
import 'package:windchime/screens/meditation/meditation_instruction_screen.dart';
import 'package:windchime/screens/meditation/meditation_session_screen.dart';
import 'package:windchime/screens/meditation/session_history_screen.dart';
import 'package:windchime/screens/about/about_screen.dart';
import 'package:windchime/screens/onboarding/welcome_tour.dart';
import 'package:windchime/services/onboarding_service.dart';
import 'package:windchime/services/in_app_purchase_service.dart';
import 'package:windchime/services/audio_download_service.dart';
import 'package:provider/provider.dart';
import 'package:windchime/providers/theme_provider.dart';
import 'package:windchime/themes/dark_theme_data.dart';
import 'package:windchime/themes/light_theme_data.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize notifications

  //Initialize database
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    sqfliteFfiInit();
  }

  // Initialize in-app purchase service
  await InAppPurchaseService.initialize();

  // Initialize audio download service
  await AudioDownloadService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isFirstTime = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    final isFirstTime = await OnboardingService.isFirstTimeUser();
    setState(() {
      _isFirstTime = isFirstTime;
      _isLoading = false;
    });
  }

  void _onWelcomeComplete() async {
    await OnboardingService.markWelcomeCompleted();
    setState(() {
      _isFirstTime = false;
    });
  }

  // Routes for Screens
  static final routes = <String, WidgetBuilder>{
    '/welcome': (context) => WelcomeTour(
          onComplete: () => Navigator.of(context).pop(),
          isFromHome: true,
        ),
    '/meditation/home': (context) => const MeditationHomeScreen(),
    '/meditation/instructions': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return MeditationInstructionScreen(
        breathingPattern: args['breathingPattern'] as BreathingPattern,
        meditation: args['meditation'] as Meditation,
      );
    },
    '/meditation/session': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return OptimizedMeditationSessionScreen(
        breathingPattern: args['breathingPattern'] as BreathingPattern,
        meditation: args['meditation'] as Meditation,
        onClose: () => Navigator.of(context).pop(),
      );
    },
    '/meditation/history': (context) => const SessionHistoryScreen(),
    '/about': (context) => const AboutScreen(),
  };

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: darkThemeData,
        home: const Scaffold(
          backgroundColor: Color(0xFF121212),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Update system theme detection in provider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final brightness = MediaQuery.of(context).platformBrightness;
            themeProvider.updateSystemTheme(brightness == Brightness.dark);
          });

          // Determine the theme based on the selected mode
          ThemeData themeData;
          switch (themeProvider.themeMode) {
            case ThemeModeOption.light:
              themeData = lightThemeData;
              break;
            case ThemeModeOption.dark:
              themeData = darkThemeData;
              break;
            case ThemeModeOption.system:
              // For system mode, use the provider's system theme detection
              themeData =
                  themeProvider.isDarkTheme ? darkThemeData : lightThemeData;
              break;
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeData,
            home: _isFirstTime
                ? WelcomeTour(onComplete: _onWelcomeComplete)
                : const RedesignedHomeScreen(),
            routes: routes,
          );
        },
      ),
    );
  }
}
