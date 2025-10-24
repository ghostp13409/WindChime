import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoodTrackerWidget extends StatefulWidget {
  const MoodTrackerWidget({super.key});

  @override
  State<MoodTrackerWidget> createState() => _MoodTrackerWidgetState();
}

class _MoodTrackerWidgetState extends State<MoodTrackerWidget> {
  String? _selectedMood;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Happy', 'color': const Color(0xFFFFD700)},
    {'emoji': '😌', 'label': 'Calm', 'color': const Color(0xFF4A90E2)},
    {'emoji': '😰', 'label': 'Anxious', 'color': const Color(0xFF9B59B6)},
    {'emoji': '😴', 'label': 'Tired', 'color': const Color(0xFF95A5A6)},
    {'emoji': '😐', 'label': 'Neutral', 'color': const Color(0xFF7F8C8D)},
  ];

  // Mock data for the trend chart (last 7 days)
  final List<double> _moodTrendData = [3.5, 4.0, 3.0, 4.5, 4.0, 3.5, 4.0];
  final List<String> _weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  void _onMoodSelected(String mood) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedMood = mood;
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feeling $mood today! 💙'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onChartTapped() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Detailed mood analytics coming soon! 📈'),
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

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'How are you feeling today?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
          ),
          const SizedBox(height: 16),

          // Mood selector row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['label'];
              return GestureDetector(
                onTap: () => _onMoodSelected(mood['label'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (mood['color'] as Color).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (mood['color'] as Color)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        child: Text(
                          mood['emoji'] as String,
                          style: TextStyle(
                            fontSize: isSelected ? 40 : 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['label'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? (mood['color'] as Color)
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Trend chart section
          GestureDetector(
            onTap: _onChartTapped,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Mood Trend (7 days)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Simple line chart
                  SizedBox(
                    height: 80,
                    child: CustomPaint(
                      size: const Size(double.infinity, 80),
                      painter: MoodChartPainter(
                        data: _moodTrendData,
                        color: Theme.of(context).colorScheme.primary,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Day labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _weekDays.map((day) {
                      return Text(
                        day,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.5),
                            ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the mood trend chart
class MoodChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final bool isDark;

  MoodChartPainter({
    required this.data,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final segmentWidth = size.width / (data.length - 1);
    final maxValue = 5.0; // Mood scale 1-5
    final minValue = 1.0;

    // Calculate first point
    final firstX = 0.0;
    final firstY = size.height -
        ((data[0] - minValue) / (maxValue - minValue)) * size.height;

    path.moveTo(firstX, firstY);
    fillPath.moveTo(firstX, size.height);
    fillPath.lineTo(firstX, firstY);

    // Draw line through all points
    for (int i = 1; i < data.length; i++) {
      final x = i * segmentWidth;
      final y = size.height -
          ((data[i] - minValue) / (maxValue - minValue)) * size.height;
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * segmentWidth;
      final y = size.height -
          ((data[i] - minValue) / (maxValue - minValue)) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = isDark ? Colors.black : Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(MoodChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
