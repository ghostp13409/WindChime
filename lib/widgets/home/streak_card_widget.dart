import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StreakCardWidget extends StatefulWidget {
  const StreakCardWidget({super.key});

  @override
  State<StreakCardWidget> createState() => _StreakCardWidgetState();
}

class _StreakCardWidgetState extends State<StreakCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flameController;
  late Animation<double> _flameAnimation;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _flameAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _flameController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  void _onSharePressed() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Social sharing coming soon! 🎉'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCardTapped() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Detailed analytics coming soon! 📊'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: _onCardTapped,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.all(20),
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    primaryColor.withOpacity(0.2),
                    primaryColor.withOpacity(0.08),
                  ]
                : [
                    primaryColor.withOpacity(0.15),
                    primaryColor.withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flame emoji with animation
            AnimatedBuilder(
              animation: _flameAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _flameAnimation.value,
                  child: const Text(
                    '🔥',
                    style: TextStyle(fontSize: 48),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),

            // Streak info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        '5',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  height: 1,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Day Streak!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: 0.71, // 5/7 days to milestone
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Motivational text
                  Text(
                    'Keep it going! Only 2 days to earn the "Week Warrior" badge',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                          height: 1.3,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Share button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: _onSharePressed,
                icon: Icon(
                  Icons.share_outlined,
                  color: primaryColor,
                ),
                iconSize: 20,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: 'Share your streak',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
