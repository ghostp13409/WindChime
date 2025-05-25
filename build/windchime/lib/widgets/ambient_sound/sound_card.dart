import 'package:flutter/material.dart';
import 'package:windchime/models/ambient_sound/sound.dart';
import 'dart:async';

class SoundCard extends StatefulWidget {
  final Sound sound;
  final VoidCallback onTap;
  final bool isPlaying;

  const SoundCard({
    super.key,
    required this.sound,
    required this.onTap,
    required this.isPlaying,
  });

  @override
  _SoundCardState createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  double progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  void _startProgressTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        progress += 1 / widget.sound.duration.inSeconds;
        if (progress >= 1.0) {
          progress = 0.0;
          _timer?.cancel();
        }
      });
    });
  }

  void _handleTap() {
    _scaleController.forward(from: 0.0);
    if (widget.isPlaying) {
      _timer?.cancel();
    } else {
      _startProgressTimer();
    }
    widget.onTap();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds % 60);
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: _scaleController,
          curve: Curves.easeInOut,
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) => _scaleController.reverse(),
        onTapCancel: () => _scaleController.reverse(),
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getGradientColors(widget.sound.category),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _getCategoryBackground(widget.sound.category),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.sound.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.sound.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(widget.sound.category),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(Duration(
                                seconds:
                                    (progress * widget.sound.duration.inSeconds)
                                        .toInt(),
                              )),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            Text(
                              _formatDuration(widget.sound.duration),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCategoryBackground(String category) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.1),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _BackgroundPatternPainter(category),
      ),
    );
  }

  List<Color> _getGradientColors(String category) {
    switch (category) {
      case 'Deep Sleep':
        return [
          const Color(0xFF2C5364),
          const Color(0xFF203A43),
        ];
      case 'Happy Music':
        return [
          const Color(0xFFFF6B6B),
          const Color(0xFF556270),
        ];
      case 'White Noise':
        return [
          const Color(0xFF5C258D),
          const Color(0xFF4389A2),
        ];
      case 'Rain Sounds':
        return [
          const Color(0xFF3494E6),
          const Color(0xFFEC6EAD),
        ];
      default:
        return [
          const Color(0xFF614385),
          const Color(0xFF516395),
        ];
    }
  }

  Color _getProgressColor(String category) {
    switch (category) {
      case 'Deep Sleep':
        return Colors.cyanAccent;
      case 'Happy Music':
        return Colors.pinkAccent;
      case 'White Noise':
        return Colors.purpleAccent;
      case 'Rain Sounds':
        return Colors.blueAccent;
      default:
        return Colors.greenAccent;
    }
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  final String category;

  _BackgroundPatternPainter(this.category);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    switch (category) {
      case 'Deep Sleep':
        _drawWavePattern(canvas, size, paint);
        break;
      case 'Happy Music':
        _drawMusicPattern(canvas, size, paint);
        break;
      case 'White Noise':
        _drawNoisePattern(canvas, size, paint);
        break;
      case 'Rain Sounds':
        _drawRainPattern(canvas, size, paint);
        break;
      default:
        _drawDefaultPattern(canvas, size, paint);
    }
  }

  void _drawWavePattern(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    for (var i = 0; i < size.height; i += 20) {
      path.moveTo(0, i.toDouble());
      for (var x = 0; x < size.width; x += 50) {
        path.quadraticBezierTo(
          x + 25,
          i - 10,
          x + 50,
          i.toDouble(),
        );
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawMusicPattern(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < size.width; i += 30) {
      for (var j = 0; j < size.height; j += 30) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 2, paint);
      }
    }
  }

  void _drawNoisePattern(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < size.width; i += 20) {
      for (var j = 0; j < size.height; j += 20) {
        if ((i + j) % 40 == 0) {
          canvas.drawLine(
            Offset(i.toDouble(), j.toDouble()),
            Offset((i + 10).toDouble(), (j + 10).toDouble()),
            paint,
          );
        }
      }
    }
  }

  void _drawRainPattern(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < size.width; i += 20) {
      for (var j = 0; j < size.height; j += 30) {
        canvas.drawLine(
          Offset(i.toDouble(), j.toDouble()),
          Offset((i - 5).toDouble(), (j + 15).toDouble()),
          paint,
        );
      }
    }
  }

  void _drawDefaultPattern(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
