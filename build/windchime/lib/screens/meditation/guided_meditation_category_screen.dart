import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GuidedMeditationCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final String categoryDescription;
  final Color categoryColor;

  const GuidedMeditationCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryDescription,
    required this.categoryColor,
  });

  @override
  State<GuidedMeditationCategoryScreen> createState() =>
      _GuidedMeditationCategoryScreenState();
}

class _GuidedMeditationCategoryScreenState
    extends State<GuidedMeditationCategoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Define meditation data for each category
  Map<String, List<Map<String, dynamic>>> get categoryMeditations => {
        'breathing_practices': [
          {
            'title': 'Three Minute Breathing',
            'duration': '3:35',
            'description':
                'Short mindfulness exercise focusing on breath awareness',
            'source': 'Peter Morgan',
            'audioPath':
                'sounds/meditation/guided/breathing_practices/Three Minute Breathing.mp3',
            'difficulty': 'Beginner',
          },
          {
            'title': 'Five Minute Breathing',
            'duration': '5:31',
            'description': 'Extended breathing practice for deeper awareness',
            'source': 'UCLA Mindful Awareness Research Centre',
            'audioPath':
                'sounds/meditation/guided/breathing_practices/Five Minute Breathing.mp3',
            'difficulty': 'Beginner',
          },
          {
            'title': 'Six Minute Breath Awareness',
            'duration': '6:32',
            'description': 'Comprehensive breath awareness meditation',
            'source': 'Melbourne Mindfulness Centre',
            'audioPath':
                'sounds/meditation/guided/breathing_practices/Six Minute Breath Awareness.mp3',
            'difficulty': 'Intermediate',
          },
          {
            'title': 'Ten Minute Breathing',
            'duration': '9:56',
            'description': 'Extended breathing session for deep relaxation',
            'source': 'Peter Morgan',
            'audioPath':
                'sounds/meditation/guided/breathing_practices/Ten Minute Breathing.mp3',
            'difficulty': 'Intermediate',
          },
          {
            'title': 'Ten Minute Mindfulness of Breathing',
            'duration': '10:01',
            'description': 'Complete mindful breathing practice',
            'source': 'Padraig O\'Morain',
            'audioPath':
                'sounds/meditation/guided/breathing_practices/Ten Minute Mindfulness of Breathing.mp3',
            'difficulty': 'Intermediate',
          },
        ],
        'brief_mindfulness': [
          {
            'title': 'Brief Mindfulness Practice',
            'duration': '4:05',
            'description': 'Quick mindfulness reset for daily use',
            'source': 'Padraig O\'Morain',
            'audioPath':
                'sounds/meditation/guided/brief_mindfulness_practices/Brief Mindfulness Practice.mp3',
            'difficulty': 'Beginner',
          },
          {
            'title': 'The Breathing Space',
            'duration': '5:39',
            'description': 'Creating space through mindful breathing',
            'source': 'Vidyamala Burch & Breathworks',
            'audioPath':
                'sounds/meditation/guided/brief_mindfulness_practices/The Breathing Space.mp3',
            'difficulty': 'Beginner',
          },
          {
            'title': 'The Tension Release Meditation',
            'duration': '5:45',
            'description': 'Release physical and mental tension mindfully',
            'source': 'Vidyamala Burch & Breathworks',
            'audioPath':
                'sounds/meditation/guided/brief_mindfulness_practices/The Tension Release Meditation.mp3',
            'difficulty': 'Beginner',
          },
          {
            'title': 'Three Step Breathing Space',
            'duration': '3:34',
            'description': 'Three-step approach to mindful awareness',
            'source': 'Peter Morgan',
            'audioPath':
                'sounds/meditation/guided/brief_mindfulness_practices/Three Step Breathing Space.mp3',
            'difficulty': 'Beginner',
          },
          {
            'title': 'Three Minute Mindfulness of Sounds',
            'duration': '3:02',
            'description': 'Cultivate awareness through sound meditation',
            'source': 'Peter Morgan',
            'audioPath':
                'sounds/meditation/guided/brief_mindfulness_practices/Three Minute Mindfulness of Sounds.mp3',
            'difficulty': 'Beginner',
          },
        ],
        'body_scan': [
          {
            'title': 'Four Minute Body Scan',
            'duration': '4:01',
            'description': 'Quick body awareness meditation',
            'source': 'Melbourne Mindfulness Centre',
            'audioPath':
                'sounds/meditation/guided/body_scan/Four Minute Body Scan.mp3',
            'difficulty': 'Beginner',
          },
          {
            'title': 'Fifteen Minute Body Scan',
            'duration': '14:36',
            'description': 'Comprehensive body awareness practice',
            'source': 'Vidyamala Burch',
            'audioPath':
                'sounds/meditation/guided/body_scan/Fifteen Minute Body Scan.mp3',
            'difficulty': 'Intermediate',
          },
          {
            'title': 'Twenty Minute Body Scan',
            'duration': '23:12',
            'description': 'Deep body scan for complete relaxation',
            'source': 'UCSD Center for Mindfulness',
            'audioPath':
                'sounds/meditation/guided/body_scan/Twenty Minute Body Scan.mp3',
            'difficulty': 'Intermediate',
          },
          {
            'title': 'Body Scan',
            'duration': '39:50',
            'description': 'Extended body awareness meditation',
            'source': 'Kieran Fleck',
            'audioPath': 'sounds/meditation/guided/body_scan/Body Scan.mp3',
            'difficulty': 'Advanced',
          },
          {
            'title': 'Forty-Five Minute Body Scan',
            'duration': '47:34',
            'description': 'Complete comprehensive body scan practice',
            'source': 'UCSD Center for Mindfulness',
            'audioPath':
                'sounds/meditation/guided/body_scan/Forty-Five Minute Body Scan.mp3',
            'difficulty': 'Advanced',
          },
        ],
        'sitting_meditations': [
          {
            'title': 'Seated Meditation',
            'duration': '21:03',
            'description': 'Traditional seated meditation practice',
            'source': 'UCSD Center for Mindfulness',
            'audioPath':
                'sounds/meditation/guided/sitting_meditations/Seated Meditation.mp3',
            'difficulty': 'Intermediate',
          },
          {
            'title': 'Sitting Meditation',
            'duration': '20:18',
            'description': 'Classic sitting meditation technique',
            'source': 'Kieran Fleck',
            'audioPath':
                'sounds/meditation/guided/sitting_meditations/Sitting Meditation.mp3',
            'difficulty': 'Intermediate',
          },
          {
            'title': 'Breath, Sound and Body',
            'duration': '12:00',
            'description': 'Multi-sensory awareness meditation',
            'source': 'UCLA Mindful Awareness Research Centre',
            'audioPath':
                'sounds/meditation/guided/sitting_meditations/Breath, Sound and Body.mp3',
            'difficulty': 'Intermediate',
          },
          {
            'title': 'Breath, Sounds, Body, Thoughts, Emotions',
            'duration': '19:00',
            'description': 'Complete awareness of all experience',
            'source': 'UCLA Mindful Awareness Research Centre',
            'audioPath':
                'sounds/meditation/guided/sitting_meditations/Breath, Sounds, Body, Thoughts, Emotions.mp3',
            'difficulty': 'Advanced',
          },
          {
            'title': 'Ten Minute Wisdom Meditation',
            'duration': '10:26',
            'description': 'Cultivating wisdom through meditation',
            'source': 'UCSD Center for Mindfulness',
            'audioPath':
                'sounds/meditation/guided/sitting_meditations/Ten Minute Wisdom Meditation.mp3',
            'difficulty': 'Intermediate',
          },
          {
            'title': 'Compassionate Breath',
            'duration': '11:33',
            'description': 'Breathing with compassion and kindness',
            'source': 'Vidyamala Burch',
            'audioPath':
                'sounds/meditation/guided/sitting_meditations/Compassionate Breath.mp3',
            'difficulty': 'Intermediate',
          },
        ],
        'guided_imagery': [
          {
            'title': 'Mountain Meditation',
            'duration': '8:12',
            'description': 'Visualize yourself as a mountain for stability',
            'source': 'Peter Morgan',
            'audioPath':
                'sounds/meditation/guided/guided_imagery/Mountain Meditation.mp3',
            'difficulty': 'Beginner',
          },
          {
            'title': 'Mountain Meditation',
            'duration': '7:17',
            'description': 'Alternative mountain visualization practice',
            'source': 'Padraig O\'Morain',
            'audioPath':
                'sounds/meditation/guided/guided_imagery/PadraigTheMountain.mp3',
            'difficulty': 'Beginner',
          },
        ],
        'self_guided': [
          {
            'title': 'Five Minutes Just Bells',
            'duration': '5:32',
            'description': 'Silent meditation with beginning and ending bells',
            'source': 'Mindfulness Bells',
            'audioPath':
                'sounds/meditation/guided/self_guided_mindfulness_exercises/Five Minutes Just Bells.mp3',
            'difficulty': 'Beginner',
          },
          {
            'title': 'Ten Minutes Just Bells',
            'duration': '10:32',
            'description': 'Extended silent practice with bell markers',
            'source': 'Mindfulness Bells',
            'audioPath':
                'sounds/meditation/guided/self_guided_mindfulness_exercises/Ten Minutes Just Bells.mp3',
            'difficulty': 'Beginner',
          },
          {
            'title': 'Twenty Minutes Just Bells',
            'duration': '20:30',
            'description': 'Longer silent meditation with bells',
            'source': 'Mindfulness Bells',
            'audioPath':
                'sounds/meditation/guided/self_guided_mindfulness_exercises/Twenty Minutes Just Bells.mp3',
            'difficulty': 'Intermediate',
          },
          {
            'title': 'Twenty Minute Bells (5 min intervals)',
            'duration': '20:29',
            'description': 'Structured meditation with 5-minute interval bells',
            'source': 'Mindfulness Bells',
            'audioPath':
                'sounds/meditation/guided/self_guided_mindfulness_exercises/Twenty Minute Bells (5 min intervals).mp3',
            'difficulty': 'Intermediate',
          },
          {
            'title': 'Twenty-Five Minute Bells (5 min intervals)',
            'duration': '25:31',
            'description': 'Extended practice with regular bell intervals',
            'source': 'Mindfulness Bells',
            'audioPath':
                'sounds/meditation/guided/self_guided_mindfulness_exercises/Twenty-Five Minute Bells (5 min intervals).mp3',
            'difficulty': 'Intermediate',
          },
          {
            'title': 'Thirty Minute Bells (5 min intervals)',
            'duration': '30:28',
            'description': 'Half-hour meditation with interval structure',
            'source': 'Mindfulness Bells',
            'audioPath':
                'sounds/meditation/guided/self_guided_mindfulness_exercises/Thirty Minute Bells (5 min intervals).mp3',
            'difficulty': 'Advanced',
          },
          {
            'title': 'Forty-Five Minute Bells (15 min intervals)',
            'duration': '45:33',
            'description': 'Long meditation with 15-minute bell intervals',
            'source': 'Mindfulness Bells',
            'audioPath':
                'sounds/meditation/guided/self_guided_mindfulness_exercises/Forty-Five Minute Bells (15 min intervals).mp3',
            'difficulty': 'Advanced',
          },
          {
            'title': 'Forty-Five Minute Bells (5 min intervals)',
            'duration': '45:35',
            'description': 'Extended meditation with frequent bell intervals',
            'source': 'Mindfulness Bells',
            'audioPath':
                'sounds/meditation/guided/self_guided_mindfulness_exercises/Forty-Five Minute Bells (5 min intervals).mp3',
            'difficulty': 'Advanced',
          },
        ],
      };

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getCategoryDescription() {
    switch (widget.categoryId) {
      case 'breathing_practices':
        return 'These short mindfulness exercises focus on bringing awareness to the breath. Observing your breath helps bring you into the present moment and develop mindfulness.';
      case 'brief_mindfulness':
        return 'These shorter mindfulness sessions are ideal for brief resets during your day. They provide quick grounding through breath, sound, and bodily awareness.';
      case 'body_scan':
        return 'Body scan meditations invite you to move your attention through different parts of the body, observing sensations and cultivating present-moment awareness.';
      case 'sitting_meditations':
        return 'Sitting meditations often center on the breath, while also inviting awareness of sounds, bodily sensations, thoughts, or emotions as they arise.';
      case 'guided_imagery':
        return 'Guided imagery uses visualization and imagination to foster calm, resilience, and emotional balance.';
      case 'self_guided':
        return 'These self-guided tracks begin and end with a bell. Some include interval bells to help structure your silent practice.';
      default:
        return 'Explore guided meditation practices for mindfulness and inner peace.';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFFFF9800);
      case 'advanced':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  void _startMeditation(Map<String, dynamic> meditation) {
    // TODO: Navigate to meditation session screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${meditation['title']}...'),
        backgroundColor: widget.categoryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          // Back button matching home screen style
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.8),
              ),
              iconSize: 22,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(width: 16),

          // Category icon matching home screen style
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  widget.categoryColor,
                  widget.categoryColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.categoryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Icon(
                _getCategoryIcon(),
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title and subtitle exactly like home screen
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                ),
                Text(
                  'Guided meditation practices',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.withOpacity(0.8),
                        letterSpacing: 0.2,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.categoryId) {
      case 'breathing_practices':
        return Icons.air;
      case 'brief_mindfulness':
        return Icons.self_improvement;
      case 'body_scan':
        return Icons.accessibility_new;
      case 'sitting_meditations':
        return Icons.event_seat;
      case 'guided_imagery':
        return Icons.landscape;
      case 'self_guided':
        return Icons.notifications_none;
      default:
        return Icons.self_improvement;
    }
  }

  Widget _buildCategoryDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.categoryTitle,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.5,
                  fontSize: 32,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _getCategoryDescription(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.3,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationCard(Map<String, dynamic> meditation) {
    final difficultyColor = _getDifficultyColor(meditation['difficulty']);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _startMeditation(meditation);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Subtle gradient overlay matching home screen
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.categoryColor.withOpacity(0.08),
                      widget.categoryColor.withOpacity(0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Play button with elegant styling matching home screen
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.categoryColor.withOpacity(0.2),
                            widget.categoryColor.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 28,
                        color: widget.categoryColor,
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            meditation['title'],
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                  height: 1.2,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Duration and difficulty row
                          Row(
                            children: [
                              Text(
                                meditation['duration'],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: widget.categoryColor,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.1,
                                    ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: difficultyColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  meditation['difficulty'],
                                  style: TextStyle(
                                    color: difficultyColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Description
                          Text(
                            meditation['description'],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.withOpacity(0.8),
                                      height: 1.4,
                                      letterSpacing: 0.1,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          // Source/Author
                          Text(
                            'by ${meditation['source']}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.withOpacity(0.6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    final meditations = categoryMeditations[widget.categoryId] ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Modern Header exactly like home screen
              _buildModernHeader(),

              // Category description section
              _buildCategoryDescription(),

              const SizedBox(height: 24),

              // Meditations list
              Expanded(
                child: meditations.isEmpty
                    ? Center(
                        child: Text(
                          'No meditations available',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey.withOpacity(0.6),
                                  ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: meditations.length,
                        itemBuilder: (context, index) {
                          return _buildMeditationCard(meditations[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
