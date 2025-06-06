import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windchime/screens/onboarding/welcome_screen.dart';
import 'package:windchime/screens/onboarding/breathwork_tutorial_screen.dart';
import 'package:windchime/screens/onboarding/guided_tutorial_screen.dart';

class WelcomeTour extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isFromHome;

  const WelcomeTour({
    super.key,
    required this.onComplete,
    this.isFromHome = false,
  });

  @override
  State<WelcomeTour> createState() => _WelcomeTourState();
}

class _WelcomeTourState extends State<WelcomeTour>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _skipTour() {
    HapticFeedback.lightImpact();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Top navigation bar with skip button
              if (!widget.isFromHome)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page indicators
                      Row(
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(0xFF7B65E4)
                                  : Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      // Skip button
                      TextButton(
                        onPressed: _skipTour,
                        child: Text(
                          'Skip',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),

              // PageView content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    WelcomeScreen(
                      onComplete: _nextPage,
                      isInTour: true,
                      isFromHome: widget.isFromHome,
                    ),
                    BreathworkTutorialScreen(
                      onNext: _nextPage,
                      onSkip: _skipTour,
                    ),
                    GuidedTutorialScreen(
                      onComplete: widget.onComplete,
                      onSkip: _skipTour,
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
}
