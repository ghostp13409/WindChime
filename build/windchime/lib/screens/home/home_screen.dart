import 'package:flutter/material.dart';
import 'package:windchime/models/home_screen/menu_item.dart';
import 'package:windchime/widgets/main_menu/menu_items_row.dart';
import 'package:windchime/widgets/meditation/meditaiton_items.dart';
import 'package:windchime/widgets/shared/quote_of_day.dart';
import 'package:windchime/services/utils/sound_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MenuItem> menuItems = [
    MenuItem(
      title: 'Journal',
      subtitle: 'Maternalize your thoughts',
      icon: Icons.book,
      route: '/journal',
      color: Color(0xFF00C896), // Vibrant teal/emerald green
    ),
    MenuItem(
      title: 'Ambient Sounds',
      subtitle: 'Focus & Relax',
      icon: Icons.volume_up,
      route: '/ambient_sound/home',
      color: Color(0xFF6C5CE7), // Vibrant purple
    ),
    MenuItem(
      title: 'Map',
      subtitle: 'Find Help',
      icon: Icons.local_hospital,
      route: '/map',
      color: Color(0xFFFF6B8A), // Vibrant pink
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Play welcome chime sound when the home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playSound('sounds/startup/completetask.mp3');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    // Logo and App Name
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'WindChime',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),

                    // Spacer to push about button to the right
                    const Spacer(),

                    // About Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/about');
                        },
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        tooltip: 'About',
                        iconSize: 20,
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: QuoteOfDay(),
              ),
            ),
            // Meditation Items
            MeditationItems(),
            // Menu Items Row
            MenuItemsRow(menuItems: menuItems),
          ],
        ),
      ),
    );
  }
}
