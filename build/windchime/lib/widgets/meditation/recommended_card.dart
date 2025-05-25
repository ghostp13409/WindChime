import 'package:flutter/material.dart';
import 'package:windchime/models/meditation/meditation.dart';

class RecommendedCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> recommendedData;
  final PageController pageController;
  final Function(Meditation) onTap;

  const RecommendedCard({
    super.key,
    required this.index,
    required this.recommendedData,
    required this.pageController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double value = 1.0;
        if (pageController.position.haveDimensions) {
          value = pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }
        return Transform.scale(
          scale: Curves.easeOutQuint.transform(value),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: () => onTap(Meditation(
            title: recommendedData['title'],
            subtitle: recommendedData['subtitle'],
            duration: '10 min',
            image: 'https://i.imgur.com/JUoBvEJ.jpg',
          )),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: recommendedData['color'],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: recommendedData['color'].withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -10,
                  right: -10,
                  child: Icon(
                    recommendedData['icon'],
                    size: 100,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Text(
                        recommendedData['title'],
                        style: TextStyle(
                          color: recommendedData['textColor'],
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        recommendedData['subtitle'],
                        style: TextStyle(
                          color: recommendedData['textColor'].withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'START',
                              style: TextStyle(
                                color: recommendedData['textColor'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '10 MIN',
                            style: TextStyle(
                              color: recommendedData['textColor'],
                              fontWeight: FontWeight.w500,
                            ),
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
      ),
    );
  }
}
