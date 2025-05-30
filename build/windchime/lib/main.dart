import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:windchime/models/meditation/breathing_pattern.dart';
import 'package:windchime/models/meditation/meditation.dart';
import 'package:windchime/screens/ambient_sound/home_screen_ambient_sound.dart';
import 'package:windchime/screens/home/home_screen.dart';
import 'package:windchime/screens/meditation/home_screen.dart';
import 'package:windchime/screens/meditation/meditation_instruction_screen.dart';
import 'package:windchime/screens/meditation/optimized_meditation_session_screen.dart';
import 'package:windchime/screens/meditation/session_history_screen.dart';
import 'package:windchime/screens/journal/journal_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:windchime/providers/theme_provider.dart';
import 'package:windchime/themes/dark_theme_data.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:windchime/screens/Map/map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications

  //Initialize database
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    sqfliteFfiInit();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // Routes for Screens
  static final routes = <String, WidgetBuilder>{
    '/': (context) => const HomeScreen(),
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
    '/journal': (context) => JournalHomeScreen(),
    '/ambient_sound/home': (context) => const HomeScreenAmbientSound(),
    '/map': (context) => const MapScreen()
  };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: darkThemeData,
            routes: routes,
            initialRoute: '/',
          );
        },
      ),
    );
  }
}
