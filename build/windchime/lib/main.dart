import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prog2435_final_project_app/models/meditation/breathing_pattern.dart';
import 'package:prog2435_final_project_app/models/meditation/meditation.dart';
import 'package:prog2435_final_project_app/screens/ambient_sound/home_screen_ambient_sound.dart';
import 'package:prog2435_final_project_app/services/notification_service.dart';
import 'package:prog2435_final_project_app/screens/habit_tracker/habit_tracker_home_screen.dart';
import 'package:prog2435_final_project_app/screens/home/home_screen.dart';
import 'package:prog2435_final_project_app/screens/meditation/home_screen.dart';
import 'package:prog2435_final_project_app/screens/meditation/meditation_session_screen.dart';
import 'package:prog2435_final_project_app/screens/meditation/session_history_screen.dart';
import 'package:prog2435_final_project_app/screens/todo/add_todo.dart';
import 'package:prog2435_final_project_app/screens/todo/todo_list.dart';
import 'package:prog2435_final_project_app/screens/journal/journal_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:prog2435_final_project_app/providers/theme_provider.dart';
import 'package:prog2435_final_project_app/themes/dark_theme_data.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:prog2435_final_project_app/screens/Map/map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

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
    '/meditation/session': (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return MeditationSessionScreen(
        breathingPattern: args['breathingPattern'] as BreathingPattern,
        meditation: args['meditation'] as Meditation,
        onClose: () => Navigator.of(context).pop(),
      );
    },
    '/meditation/history': (context) => const SessionHistoryScreen(),
    '/habit_tracker': (context) => const HabitListScreen(),
    '/todo': (context) => const TodoListScreen(),
    '/todo/add': (context) => AddTodoFormScreen(),
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
