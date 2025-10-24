import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class QuickSessionFAB extends StatefulWidget {
  final VoidCallback? onPressed;

  const QuickSessionFAB({
    super.key,
    this.onPressed,
  });

  @override
  State<QuickSessionFAB> createState() => _QuickSessionFABState();
}

class _QuickSessionFABState extends State<QuickSessionFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showQuickMenu = false;

  final List<Map<String, dynamic>> _quickSessions = [
    {
      'icon': Icons.nightlight_round,
      'label': 'Sleep',
      'duration': '10 min',
      'color': const Color(0xFF6B46C1),
    },
    {
      'icon': Icons.psychology,
      'label': 'Focus',
      'duration': '5 min',
      'color': const Color(0xFFEA580C),
    },
    {
      'icon': Icons.healing,
      'label': 'Calm',
      'duration': '8 min',
      'color': const Color(0xFF059669),
    },
    {
      'icon': Icons.wb_sunny,
      'label': 'Energy',
      'duration': '3 min',
      'color': const Color(0xFFF59E0B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onFABPressed() {
    HapticFeedback.mediumImpact();

    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      _showQuickSessionDialog();
    }
  }

  void _onFABLongPress() {
    HapticFeedback.heavyImpact();
    setState(() {
      _showQuickMenu = !_showQuickMenu;
    });
  }

  void _showQuickSessionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.bolt,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Quick Session'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _quickSessions.map((session) {
            return _buildQuickSessionOption(
              session['icon'] as IconData,
              session['label'] as String,
              session['duration'] as String,
              session['color'] as Color,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuickSessionOption(
    IconData icon,
    String label,
    String duration,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting $label meditation ($duration) ✨'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    duration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Pulsing glow effect
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 64 * _pulseAnimation.value,
              height: 64 * _pulseAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        ),

        // Main FAB
        GestureDetector(
          onLongPress: _onFABLongPress,
          child: FloatingActionButton(
            onPressed: _onFABPressed,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _pulseController.value * 0.1,
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Quick menu (if enabled in future)
        if (_showQuickMenu)
          Positioned(
            bottom: 80,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  alignment: Alignment.bottomRight,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _quickSessions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final session = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < _quickSessions.length - 1 ? 8 : 0,
                      ),
                      child: _buildQuickMenuButton(
                        session['icon'] as IconData,
                        session['label'] as String,
                        session['color'] as Color,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickMenuButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _showQuickMenu = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Starting $label meditation ✨'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
