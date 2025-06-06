/*
 * Copyright (C) 2025 Parth Gajjar
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

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
          'A foundational breathing practice using 4-7-8 technique: inhale for 4 seconds, hold for 7, exhale for 8. This pattern activates the parasympathetic nervous system for natural relaxation and stress relief.',
      categoryId: 'breathing_practices',
      audioPath:
          'assets/sounds/meditation/guided/breathing_practices/Three Minute Breathing.mp3',
      durationSeconds: 215, // 3:35
      instructor: 'Peter Morgan',
      tags: ['beginner', 'quick', 'breath', '4-7-8', 'anxiety-relief'],
      isPopular: true,
      detailedDescription:
          'This guided practice introduces the scientifically-backed 4-7-8 breathing technique developed by Dr. Andrew Weil. The extended exhale phase naturally triggers your body\'s relaxation response, making it ideal for reducing anxiety and promoting calm.',
      whatToExpect:
          'You\'ll be guided through rhythmic breathing cycles that may initially feel challenging but become more natural with practice. Many people notice immediate calming effects, with some experiencing slight dizziness (normal) as your body adjusts to increased oxygen.',
      researchLinks: [
        ResearchLink(
          title: 'The Science of 4-7-8 Breathing',
          url:
              'https://www.drweil.com/health-wellness/body-mind-spirit/stress-anxiety/breathing-three-exercises/',
          authors: 'Dr. Andrew Weil',
          description:
              'Original research on the 4-7-8 breathing technique for anxiety and sleep',
        ),
      ],
    ),
    GuidedMeditation(
      id: 'five_minute_breathing_ucla',
      title: 'Five Minute Breathing',
      description:
          'Box breathing practice (4-4-4-4 pattern) used by Navy SEALs and meditation practitioners. Equal intervals of inhale, hold, exhale, hold create rhythmic neural entrainment for enhanced focus and reduced stress.',
      categoryId: 'breathing_practices',
      audioPath:
          'assets/sounds/meditation/guided/breathing_practices/Five Minute Breathing.mp3',
      durationSeconds: 331, // 5:31
      instructor: 'UCLA MARC',
      tags: ['beginner', 'breath', 'mindfulness', 'box-breathing', 'focus'],
      detailedDescription:
          'Box breathing, also known as tactical breathing, is extensively used by military units and first responders for stress management. This practice creates balanced autonomic nervous system activation, improving both focus and calm.',
      whatToExpect:
          'The equal timing may feel mechanical at first, but creates a meditative rhythm. You\'ll likely notice improved focus and a sense of balanced alertness without anxiety.',
      researchLinks: [
        ResearchLink(
          title: 'Breath of life: the respiratory vagal stimulation model',
          url: 'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6189422/',
          authors: 'Gerritsen, R.J. & Band, G.P.',
          description:
              'Research on how rhythmic breathing patterns enhance focus and decision-making',
        ),
      ],
    ),
    GuidedMeditation(
      id: 'six_minute_breath_awareness',
      title: 'Six Minute Breath Awareness',
      description:
          'Sleep-inducing breathing with 4:6 ratio (4 seconds inhale, 6 seconds exhale). The extended exhale activates the vagus nerve and parasympathetic nervous system for natural sleep preparation.',
      categoryId: 'breathing_practices',
      audioPath:
          'assets/sounds/meditation/guided/breathing_practices/Six Minute Breath Awareness.mp3',
      durationSeconds: 392, // 6:32
      instructor: 'Melbourne Mindfulness Centre',
      tags: ['breath', 'awareness', 'intermediate', 'sleep-prep', 'relaxation'],
      detailedDescription:
          'This practice uses the optimal 4:6 breathing ratio for sleep induction. Research shows that longer exhales than inhales consistently activate the body\'s natural sleep mechanisms without the stress of extreme breath holds.',
      whatToExpect:
          'You\'ll feel progressively more relaxed as the extended exhales signal your nervous system to prepare for rest. This is excellent preparation for sleep or deep relaxation.',
      researchLinks: [
        ResearchLink(
          title:
              'Self-regulation of breathing as primary treatment for anxiety',
          url: 'https://link.springer.com/article/10.1007/s10484-015-9279-8',
          authors: 'Jerath, R., et al.',
          description:
              'Clinical research on exhale-focused breathing for sleep and anxiety relief',
        ),
      ],
    ),
    GuidedMeditation(
      id: 'ten_minute_breathing',
      title: 'Ten Minute Breathing',
      description:
          'Physiological sigh breathing (4:8 ratio) based on Stanford neuroscience research. This 2:1 exhale-to-inhale ratio maximally activates the parasympathetic nervous system for rapid anxiety reduction.',
      categoryId: 'breathing_practices',
      audioPath:
          'assets/sounds/meditation/guided/breathing_practices/Ten Minute Breathing.mp3',
      durationSeconds: 596, // 9:56
      instructor: 'Peter Morgan',
      tags: [
        'intermediate',
        'breath',
        'extended',
        'anxiety-relief',
        'physiological-sigh'
      ],
      detailedDescription:
          'Based on Dr. Andrew Huberman\'s Stanford research on physiological sighs, this pattern provides the most effective breathing technique for rapid anxiety reduction. The 2:1 exhale ratio eliminates breath holds that can increase stress in beginners.',
      whatToExpect:
          'You may notice almost immediate anxiety relief as this pattern directly targets your nervous system\'s stress response. The longer exhales help discharge tension and promote calm.',
      researchLinks: [
        ResearchLink(
          title: 'Brief structured respiration practices enhance mood',
          url: 'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9860365/',
          authors: 'Balban, M.Y., et al.',
          description:
              'Stanford research showing physiological sighs as most effective for anxiety reduction',
        ),
      ],
    ),
    GuidedMeditation(
      id: 'ten_minute_mindfulness_breathing',
      title: 'Ten Minute Mindfulness of Breathing',
      description:
          'Energizing 1:1 breathing (3 seconds inhale, 3 seconds exhale) for balanced mood and alertness. This equal ratio promotes balanced sympathetic/parasympathetic activity for positive emotional states.',
      categoryId: 'breathing_practices',
      audioPath:
          'assets/sounds/meditation/guided/breathing_practices/Ten Minute Mindfulness of Breathing.mp3',
      durationSeconds: 601, // 10:01
      instructor: 'Padraig O\'Morain',
      tags: [
        'mindfulness',
        'breath',
        'comprehensive',
        'energizing',
        'mood-boost'
      ],
      detailedDescription:
          'This balanced breathing pattern maintains alertness for positive mood without triggering stress responses. The 3-second intervals are sustainable and research-optimal for most people, promoting emotional well-being and cognitive clarity.',
      whatToExpect:
          'You\'ll feel alert yet calm, with a natural mood lift. This practice is excellent for starting your day or when you need focused, positive energy.',
      researchLinks: [
        ResearchLink(
          title: 'How breath-control can change your life',
          url:
              'https://www.frontiersin.org/articles/10.3389/fnhum.2018.00353/full',
          authors: 'Zaccaro, A., et al.',
          description:
              'Systematic review on how balanced breathing ratios affect mood and cognition',
        ),
      ],
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
          'assets/sounds/meditation/guided/guided_imagery/MindfulnessMountainMeditationPeterMorgan.mp3',
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
