import 'package:windchime/models/meditation/guided_meditation.dart';
import 'package:windchime/models/meditation/guided_meditation_category.dart';

class GuidedMeditationRepository {
  static final GuidedMeditationRepository _instance =
      GuidedMeditationRepository._internal();
  factory GuidedMeditationRepository() => _instance;
  GuidedMeditationRepository._internal();

  // Predefined guided meditations based on the asset files
  static const List<GuidedMeditation> _guidedMeditations = [
    // Breathing Practices
    GuidedMeditation(
      id: 'three_minute_breathing',
      title: 'Three Minute Breathing',
      description:
          'A short mindfulness exercise focusing on breath awareness to bring you into the present moment.',
      categoryId: 'breathing_practices',
      audioPath:
          'assets/sounds/meditation/guided/breathing_practices/Three Minute Breathing.mp3',
      durationSeconds: 215, // 3:35
      instructor: 'Peter Morgan',
      tags: ['beginner', 'quick', 'breath'],
      isPopular: true,
    ),
    GuidedMeditation(
      id: 'five_minute_breathing_ucla',
      title: 'Five Minute Breathing',
      description:
          'UCLA Mindful Awareness Research Centre guided breathing meditation for developing mindfulness.',
      categoryId: 'breathing_practices',
      audioPath:
          'assets/sounds/meditation/guided/breathing_practices/Five Minute Breathing.mp3',
      durationSeconds: 331, // 5:31
      instructor: 'UCLA MARC',
      tags: ['beginner', 'breath', 'mindfulness'],
    ),
    GuidedMeditation(
      id: 'six_minute_breath_awareness',
      title: 'Six Minute Breath Awareness',
      description:
          'Develop deeper awareness of your breath with this guided meditation from Melbourne Mindfulness Centre.',
      categoryId: 'breathing_practices',
      audioPath:
          'assets/sounds/meditation/guided/breathing_practices/Six Minute Breath Awareness.mp3',
      durationSeconds: 392, // 6:32
      instructor: 'Melbourne Mindfulness Centre',
      tags: ['breath', 'awareness', 'intermediate'],
    ),
    GuidedMeditation(
      id: 'ten_minute_breathing',
      title: 'Ten Minute Breathing',
      description:
          'Extended breathing meditation for deeper mindfulness practice and sustained attention.',
      categoryId: 'breathing_practices',
      audioPath:
          'assets/sounds/meditation/guided/breathing_practices/Ten Minute Breathing.mp3',
      durationSeconds: 596, // 9:56
      instructor: 'Peter Morgan',
      tags: ['intermediate', 'breath', 'extended'],
    ),
    GuidedMeditation(
      id: 'ten_minute_mindfulness_breathing',
      title: 'Ten Minute Mindfulness of Breathing',
      description:
          'Comprehensive mindfulness of breathing practice with detailed guidance.',
      categoryId: 'breathing_practices',
      audioPath:
          'assets/sounds/meditation/guided/breathing_practices/Ten Minute Mindfulness of Breathing.mp3',
      durationSeconds: 601, // 10:01
      instructor: 'Padraig O\'Morain',
      tags: ['mindfulness', 'breath', 'comprehensive'],
    ),

    // Brief Mindfulness Practices
    GuidedMeditation(
      id: 'brief_mindfulness_practice',
      title: 'Brief Mindfulness Practice',
      description:
          'Quick mindfulness reset ideal for busy schedules and daily stress relief.',
      categoryId: 'brief_mindfulness',
      audioPath:
          'assets/sounds/meditation/guided/brief_mindfulness_practices/Brief Mindfulness Practice.mp3',
      durationSeconds: 245, // 4:05
      instructor: 'Padraig O\'Morain',
      tags: ['quick', 'stress relief', 'daily'],
      isPopular: true,
    ),
    GuidedMeditation(
      id: 'breathing_space',
      title: 'The Breathing Space',
      description:
          'A three-step breathing space practice for finding calm in challenging moments.',
      categoryId: 'brief_mindfulness',
      audioPath:
          'assets/sounds/meditation/guided/brief_mindfulness_practices/The Breathing Space.mp3',
      durationSeconds: 339, // 5:39
      instructor: 'Vidyamala Burch',
      tags: ['three-step', 'calm', 'challenging moments'],
    ),
    GuidedMeditation(
      id: 'tension_release',
      title: 'The Tension Release Meditation',
      description:
          'Release physical and mental tension through guided awareness and breath.',
      categoryId: 'brief_mindfulness',
      audioPath:
          'assets/sounds/meditation/guided/brief_mindfulness_practices/The Tension Release Meditation.mp3',
      durationSeconds: 345, // 5:45
      instructor: 'Vidyamala Burch',
      tags: ['tension release', 'relaxation', 'physical'],
    ),
    GuidedMeditation(
      id: 'three_step_breathing_space',
      title: 'Three Step Breathing Space',
      description:
          'Structured three-step approach to mindful breathing and present moment awareness.',
      categoryId: 'brief_mindfulness',
      audioPath:
          'assets/sounds/meditation/guided/brief_mindfulness_practices/Three Step Breathing Space.mp3',
      durationSeconds: 214, // 3:34
      instructor: 'Peter Morgan',
      tags: ['structured', 'three-step', 'present moment'],
    ),
    GuidedMeditation(
      id: 'mindfulness_of_sounds',
      title: 'Three Minute Mindfulness of Sounds',
      description:
          'Develop awareness of sounds around you in this brief mindfulness practice.',
      categoryId: 'brief_mindfulness',
      audioPath:
          'assets/sounds/meditation/guided/brief_mindfulness_practices/Three Minute Mindfulness of Sounds.mp3',
      durationSeconds: 182, // 3:02
      instructor: 'Peter Morgan',
      tags: ['sounds', 'awareness', 'environmental'],
    ),

    // Body Scan
    GuidedMeditation(
      id: 'four_minute_body_scan',
      title: 'Four Minute Body Scan',
      description:
          'Quick body scan meditation to develop bodily awareness and relaxation.',
      categoryId: 'body_scan',
      audioPath:
          'assets/sounds/meditation/guided/body_scan/Four Minute Body Scan.mp3',
      durationSeconds: 241, // 4:01
      instructor: 'Melbourne Mindfulness Centre',
      tags: ['quick', 'body awareness', 'beginner'],
      isPopular: true,
    ),
    GuidedMeditation(
      id: 'fifteen_minute_body_scan',
      title: 'Fifteen Minute Body Scan',
      description:
          'Comprehensive body scan meditation for deep relaxation and bodily awareness.',
      categoryId: 'body_scan',
      audioPath:
          'assets/sounds/meditation/guided/body_scan/Fifteen Minute Body Scan.mp3',
      durationSeconds: 876, // 14:36
      instructor: 'Vidyamala Burch',
      tags: ['comprehensive', 'relaxation', 'intermediate'],
    ),
    GuidedMeditation(
      id: 'twenty_minute_body_scan',
      title: 'Twenty Minute Body Scan',
      description:
          'Extended body scan practice from UCSD Center for Mindfulness for deep body awareness.',
      categoryId: 'body_scan',
      audioPath:
          'assets/sounds/meditation/guided/body_scan/Twenty Minute Body Scan.mp3',
      durationSeconds: 1392, // 23:12
      instructor: 'UCSD Center for Mindfulness',
      tags: ['extended', 'deep awareness', 'advanced'],
    ),
    GuidedMeditation(
      id: 'body_scan_kieran',
      title: 'Body Scan',
      description:
          'Comprehensive 40-minute body scan meditation for complete bodily relaxation.',
      categoryId: 'body_scan',
      audioPath: 'assets/sounds/meditation/guided/body_scan/Body Scan.mp3',
      durationSeconds: 2390, // 39:50
      instructor: 'Kieran Fleck',
      tags: ['comprehensive', 'long', 'complete relaxation'],
    ),
    GuidedMeditation(
      id: 'forty_five_minute_body_scan',
      title: 'Forty-Five Minute Body Scan',
      description:
          'Extended body scan meditation for the deepest level of bodily awareness and relaxation.',
      categoryId: 'body_scan',
      audioPath:
          'assets/sounds/meditation/guided/body_scan/Forty-Five Minute Body Scan.mp3',
      durationSeconds: 2854, // 47:34
      instructor: 'UCSD Center for Mindfulness',
      tags: ['extended', 'deep', 'advanced', 'complete'],
    ),

    // Sitting Meditations
    GuidedMeditation(
      id: 'seated_meditation',
      title: 'Seated Meditation',
      description:
          'Traditional seated meditation practice combining breath, sound, and bodily awareness.',
      categoryId: 'sitting_meditations',
      audioPath:
          'assets/sounds/meditation/guided/sitting_meditations/Seated Meditation.mp3',
      durationSeconds: 1263, // 21:03
      instructor: 'UCSD Center for Mindfulness',
      tags: ['traditional', 'comprehensive', 'seated'],
    ),
    GuidedMeditation(
      id: 'sitting_meditation_kieran',
      title: 'Sitting Meditation',
      description:
          'Focused sitting meditation practice for developing sustained attention and awareness.',
      categoryId: 'sitting_meditations',
      audioPath:
          'assets/sounds/meditation/guided/sitting_meditations/Sitting Meditation.mp3',
      durationSeconds: 1218, // 20:18
      instructor: 'Kieran Fleck',
      tags: ['focused', 'attention', 'awareness'],
    ),
    GuidedMeditation(
      id: 'breath_sound_body',
      title: 'Breath, Sound and Body',
      description:
          'Multi-faceted meditation combining awareness of breath, sounds, and bodily sensations.',
      categoryId: 'sitting_meditations',
      audioPath:
          'assets/sounds/meditation/guided/sitting_meditations/Breath, Sound and Body.mp3',
      durationSeconds: 720, // 12:00
      instructor: 'UCLA MARC',
      tags: ['multi-faceted', 'comprehensive', 'intermediate'],
      isPopular: true,
    ),
    GuidedMeditation(
      id: 'breath_sounds_body_thoughts_emotions',
      title: 'Breath, Sounds, Body, Thoughts, Emotions',
      description:
          'Comprehensive meditation covering all aspects of mindful awareness practice.',
      categoryId: 'sitting_meditations',
      audioPath:
          'assets/sounds/meditation/guided/sitting_meditations/Breath, Sounds, Body, Thoughts, Emotions.mp3',
      durationSeconds: 1140, // 19:00
      instructor: 'UCLA MARC',
      tags: ['comprehensive', 'all aspects', 'advanced'],
    ),
    GuidedMeditation(
      id: 'ten_minute_wisdom',
      title: 'Ten Minute Wisdom Meditation',
      description:
          'Wisdom-focused meditation practice for developing insight and understanding.',
      categoryId: 'sitting_meditations',
      audioPath:
          'assets/sounds/meditation/guided/sitting_meditations/Ten Minute Wisdom Meditation.mp3',
      durationSeconds: 626, // 10:26
      instructor: 'UCSD Center for Mindfulness',
      tags: ['wisdom', 'insight', 'understanding'],
    ),
    GuidedMeditation(
      id: 'compassionate_breath',
      title: 'Compassionate Breath',
      description:
          'Breathing meditation focused on developing compassion and loving-kindness.',
      categoryId: 'sitting_meditations',
      audioPath:
          'assets/sounds/meditation/guided/sitting_meditations/Compassionate Breath.mp3',
      durationSeconds: 693, // 11:33
      instructor: 'Vidyamala Burch',
      tags: ['compassion', 'loving-kindness', 'heart'],
    ),

    // Guided Imagery
    GuidedMeditation(
      id: 'mountain_meditation_peter',
      title: 'Mountain Meditation',
      description:
          'Visualization meditation using the image of a mountain for stability and grounding.',
      categoryId: 'guided_imagery',
      audioPath:
          'assets/sounds/meditation/guided/guided_imagery/Mountain Meditation.mp3',
      durationSeconds: 492, // 8:12
      instructor: 'Peter Morgan',
      tags: ['visualization', 'mountain', 'stability', 'grounding'],
      isPopular: true,
    ),
    GuidedMeditation(
      id: 'mountain_meditation_padraig',
      title: 'Mountain Meditation',
      description:
          'Mountain visualization practice for developing inner strength and resilience.',
      categoryId: 'guided_imagery',
      audioPath:
          'assets/sounds/meditation/guided/guided_imagery/PadraigTheMountain.mp3',
      durationSeconds: 437, // 7:17
      instructor: 'Padraig O\'Morain',
      tags: ['visualization', 'strength', 'resilience', 'mountain'],
    ),

    // Self Guided Mindfulness Exercises
    GuidedMeditation(
      id: 'five_minutes_bells',
      title: 'Five Minutes Just Bells',
      description:
          'Silent meditation with beginning and ending bells for self-directed practice.',
      categoryId: 'self_guided',
      audioPath:
          'assets/sounds/meditation/guided/self_guided_mindfulness_exercises/Five Minutes Just Bells.mp3',
      durationSeconds: 332, // 5:32
      instructor: 'Self Guided',
      tags: ['silent', 'bells', 'self-directed', 'beginner'],
    ),
    GuidedMeditation(
      id: 'ten_minutes_bells',
      title: 'Ten Minutes Just Bells',
      description:
          'Ten-minute silent meditation session with start and end bells.',
      categoryId: 'self_guided',
      audioPath:
          'assets/sounds/meditation/guided/self_guided_mindfulness_exercises/Ten Minutes Just Bells.mp3',
      durationSeconds: 632, // 10:32
      instructor: 'Self Guided',
      tags: ['silent', 'bells', 'intermediate'],
    ),
    GuidedMeditation(
      id: 'twenty_minutes_bells',
      title: 'Twenty Minutes Just Bells',
      description:
          'Extended silent meditation with beginning and ending bells.',
      categoryId: 'self_guided',
      audioPath:
          'assets/sounds/meditation/guided/self_guided_mindfulness_exercises/Twenty Minutes Just Bells.mp3',
      durationSeconds: 1230, // 20:30
      instructor: 'Self Guided',
      tags: ['silent', 'extended', 'advanced'],
    ),
    GuidedMeditation(
      id: 'twenty_minute_intervals',
      title: 'Twenty Minute Bells (5 min intervals)',
      description:
          'Twenty-minute session with interval bells every 5 minutes to structure your practice.',
      categoryId: 'self_guided',
      audioPath:
          'assets/sounds/meditation/guided/self_guided_mindfulness_exercises/Twenty Minute Bells (5 min intervals).mp3',
      durationSeconds: 1229, // 20:29
      instructor: 'Self Guided',
      tags: ['intervals', 'structured', 'intermediate'],
      isPopular: true,
    ),
    GuidedMeditation(
      id: 'twenty_five_minute_intervals',
      title: 'Twenty-Five Minute Bells (5 min intervals)',
      description:
          'Extended meditation with 5-minute interval bells for structured practice.',
      categoryId: 'self_guided',
      audioPath:
          'assets/sounds/meditation/guided/self_guided_mindfulness_exercises/Twenty-Five Minute Bells (5 min intervals).mp3',
      durationSeconds: 1531, // 25:31
      instructor: 'Self Guided',
      tags: ['intervals', 'extended', 'structured'],
    ),
    GuidedMeditation(
      id: 'thirty_minute_intervals',
      title: 'Thirty Minute Bells (5 min intervals)',
      description:
          'Thirty-minute meditation session with regular interval bells for guidance.',
      categoryId: 'self_guided',
      audioPath:
          'assets/sounds/meditation/guided/self_guided_mindfulness_exercises/Thirty Minute Bells (5 min intervals).mp3',
      durationSeconds: 1828, // 30:28
      instructor: 'Self Guided',
      tags: ['long', 'intervals', 'advanced'],
    ),
    GuidedMeditation(
      id: 'forty_five_minute_15_intervals',
      title: 'Forty-Five Minute Bells (15 min intervals)',
      description:
          'Extended meditation session with 15-minute interval bells for deep practice.',
      categoryId: 'self_guided',
      audioPath:
          'assets/sounds/meditation/guided/self_guided_mindfulness_exercises/Forty-Five Minute Bells (15 min intervals).mp3',
      durationSeconds: 2733, // 45:33
      instructor: 'Self Guided',
      tags: ['extended', 'deep', 'advanced', '15min-intervals'],
    ),
    GuidedMeditation(
      id: 'forty_five_minute_5_intervals',
      title: 'Forty-Five Minute Bells (5 min intervals)',
      description:
          'Long meditation session with frequent 5-minute interval bells for structured deep practice.',
      categoryId: 'self_guided',
      audioPath:
          'assets/sounds/meditation/guided/self_guided_mindfulness_exercises/Forty-Five Minute Bells (5 min intervals).mp3',
      durationSeconds: 2735, // 45:35
      instructor: 'Self Guided',
      tags: ['long', 'frequent intervals', 'advanced', 'deep'],
    ),
  ];

  // Get all categories
  List<GuidedMeditationCategory> getAllCategories() {
    return GuidedMeditationCategory.categories.values.toList();
  }

  // Get category by ID
  GuidedMeditationCategory? getCategoryById(String categoryId) {
    return GuidedMeditationCategory.categories[categoryId];
  }

  // Get all meditations
  List<GuidedMeditation> getAllMeditations() {
    return _guidedMeditations;
  }

  // Get meditations by category
  List<GuidedMeditation> getMeditationsByCategory(String categoryId) {
    return _guidedMeditations
        .where((meditation) => meditation.categoryId == categoryId)
        .toList();
  }

  // Get popular meditations
  List<GuidedMeditation> getPopularMeditations() {
    return _guidedMeditations
        .where((meditation) => meditation.isPopular)
        .toList();
  }

  // Get meditation by ID
  GuidedMeditation? getMeditationById(String meditationId) {
    try {
      return _guidedMeditations
          .firstWhere((meditation) => meditation.id == meditationId);
    } catch (e) {
      return null;
    }
  }

  // Search meditations
  List<GuidedMeditation> searchMeditations(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _guidedMeditations
        .where((meditation) =>
            meditation.title.toLowerCase().contains(lowercaseQuery) ||
            meditation.description.toLowerCase().contains(lowercaseQuery) ||
            meditation.tags
                .any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
            meditation.instructor.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Get meditations by duration range
  List<GuidedMeditation> getMeditationsByDuration(
      int minSeconds, int maxSeconds) {
    return _guidedMeditations
        .where((meditation) =>
            meditation.durationSeconds >= minSeconds &&
            meditation.durationSeconds <= maxSeconds)
        .toList();
  }

  // Get meditations by instructor
  List<GuidedMeditation> getMeditationsByInstructor(String instructor) {
    return _guidedMeditations
        .where((meditation) => meditation.instructor == instructor)
        .toList();
  }
}
