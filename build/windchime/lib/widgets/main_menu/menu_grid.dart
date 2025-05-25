import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windchime/widgets/shared/quote_of_day.dart';

class MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;

  const MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class MenuGrid extends StatefulWidget {
  const MenuGrid({super.key});

  @override
  _MenuGridState createState() => _MenuGridState();
}

class _MenuGridState extends State<MenuGrid> {
  final List<MenuItem> menuItems = [
    MenuItem(
      title: 'Meditation',
      subtitle: 'Find your inner peace',
      icon: Icons.self_improvement,
      route: '/meditation/home',
      color: Color(0xFF8E97FD),
    ),
    MenuItem(
      title: 'Journal',
      subtitle: 'Capture your thoughts',
      icon: Icons.book,
      route: '/journal',
      color: Color(0xFFF6815B),
    ),
    MenuItem(
      title: 'Habits',
      subtitle: 'Build better routines',
      icon: Icons.trending_up,
      route: '/habit_tracker',
      color: Color(0xFFFA6E5A),
    ),
    MenuItem(
      title: 'Todo List',
      subtitle: 'Stay organized',
      icon: Icons.check_circle_outline,
      route: '/todo',
      color: Color(0xFF7B65E4),
    ),
    MenuItem(
      title: 'Ambient Sounds',
      subtitle: 'Focus & relax',
      icon: Icons.volume_up,
      route: '/ambient_sound/home',
      color: Color(0xFFFFCF86),
    ),
    MenuItem(
      title: 'Map',
      subtitle: 'Find a mental health centre near you',
      icon: Icons.local_hospital,
      route: '/map',
      color: Color.fromARGB(255, 79, 124, 196),
    ),
  ];

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      'Sunrise',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(
                      width: 40,
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: QuoteOfDay(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  'What would you like to do?',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = menuItems[index];
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact(); // Add haptic feedback
                        Navigator.pushNamed(context, item.route);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? item.color.withOpacity(0.2)
                              : item.color.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: item.color,
                            width: 2,
                          ),
                          boxShadow:
                              Theme.of(context).brightness == Brightness.light
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 48,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? item.color
                                  : Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item.title,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Color(0xFF2D3142),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                item.subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(0.8)
                                      : Color(0xFF2D3142).withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: menuItems.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
