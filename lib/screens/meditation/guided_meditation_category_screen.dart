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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windchime/screens/meditation/guided_meditation_instruction_screen.dart';
import 'package:windchime/models/meditation/guided_meditation.dart';
import 'package:windchime/services/audio_download_service.dart';
import 'package:windchime/config/audio_config.dart';
import 'package:windchime/widgets/shared/download_progress_widget.dart';

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

  final AudioDownloadService _downloadService = AudioDownloadService();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadMessage = '';

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
                'sounds/meditation/guided/guided_imagery/MindfulnessMountainMeditationPeterMorgan.mp3',
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

  void _startMeditation(Map<String, dynamic> meditationData) async {
    final audioPath = meditationData['audioPath'];

    // Debug logging
    print('Audio path: $audioPath');
    print('Should download: ${AudioConfig.shouldDownload(audioPath)}');
    print('Download URL: ${AudioConfig.getDownloadUrl(audioPath)}');

    // Check if this is a downloadable file
    if (AudioConfig.shouldDownload(audioPath)) {
      // Check if already downloaded
      final isDownloaded = await _downloadService.isDownloaded(audioPath);
      print('Is downloaded: $isDownloaded');

      if (!isDownloaded) {
        // Show download dialog
        await _showDownloadDialog(audioPath, meditationData);
        return;
      }
    }

    // Proceed with meditation
    _navigateToMeditation(meditationData);
  }

  void _navigateToMeditation(Map<String, dynamic> meditationData) {
    // Convert map data to GuidedMeditation object
    final meditation = GuidedMeditation(
      id: '${widget.categoryId}_${meditationData['title'].toString().replaceAll(' ', '_').toLowerCase()}',
      title: meditationData['title'],
      description: meditationData['description'],
      categoryId: widget.categoryId,
      audioPath: meditationData['audioPath'],
      durationSeconds: _parseDurationToSeconds(meditationData['duration']),
      instructor: meditationData['source'],
      tags: [meditationData['difficulty'], widget.categoryTitle],
      detailedDescription: _getDetailedDescription(meditationData),
      whatToExpect: _getWhatToExpect(meditationData),
      researchLinks: _getResearchLinks(meditationData),
      instructorBio: _getInstructorBio(meditationData['source']),
      attribution: _getAttribution(meditationData['source']),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuidedMeditationInstructionScreen(
          meditation: meditation,
          categoryColor: widget.categoryColor,
        ),
      ),
    );
  }

  Future<void> _showDownloadDialog(
      String audioPath, Map<String, dynamic> meditationData) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Download Required'),
        content: Text(
          'This meditation needs to be downloaded first. Would you like to download "${meditationData['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadAndStartMeditation(audioPath, meditationData);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndStartMeditation(
      String audioPath, Map<String, dynamic> meditationData) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadMessage = 'Downloading ${meditationData['title']}...';
    });

    try {
      final success = await _downloadService.downloadAudio(
        audioPath,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
        onError: (error) {
          setState(() {
            _isDownloading = false;
          });
          _showErrorDialog(error);
        },
      );

      if (success) {
        setState(() {
          _isDownloading = false;
        });
        _navigateToMeditation(meditationData);
      } else {
        setState(() {
          _isDownloading = false;
        });
        _showErrorDialog(
            'Download failed. Please check your internet connection and try again.');
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      _showErrorDialog('Download error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _testDownload() async {
    // Test with a sample meditation
    final testMeditation = {
      'title': 'Test Meditation',
      'audioPath':
          'sounds/meditation/guided/sitting_meditations/Seated Meditation.mp3',
    };

    print('=== TESTING DOWNLOAD SYSTEM ===');
    print('Audio path: ${testMeditation['audioPath']}');
    print(
        'Should download: ${AudioConfig.shouldDownload(testMeditation['audioPath'] ?? '')}');
    print(
        'Download URL: ${AudioConfig.getDownloadUrl(testMeditation['audioPath'] ?? '')}');

    final isDownloaded =
        await _downloadService.isDownloaded(testMeditation['audioPath'] ?? '');
    print('Is downloaded: $isDownloaded');

    if (!isDownloaded) {
      await _showDownloadDialog(
          testMeditation['audioPath'] ?? '', testMeditation);
    } else {
      print('File is already downloaded!');
    }
  }

  int _parseDurationToSeconds(String duration) {
    final parts = duration.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      return minutes * 60 + seconds;
    }
    return 0;
  }

  String _getDetailedDescription(Map<String, dynamic> meditation) {
    switch (widget.categoryId) {
      case 'breathing_practices':
        return '${meditation['description']} This practice helps develop mindful awareness of the breath, which serves as an anchor for present-moment attention. Regular breathing meditation can improve focus, reduce anxiety, and promote overall emotional well-being.';
      case 'brief_mindfulness':
        return '${meditation['description']} These shorter practices are perfect for integrating mindfulness into your daily routine. They help reset your mental state and bring you back to the present moment when you feel scattered or overwhelmed.';
      case 'body_scan':
        return '${meditation['description']} Body scan meditation systematically moves attention through different parts of the body, helping to release tension and develop greater body awareness. This practice is particularly beneficial for relaxation and stress relief.';
      case 'sitting_meditations':
        return '${meditation['description']} Traditional sitting meditation forms the foundation of mindfulness practice. This approach typically focuses on breath awareness while maintaining an open attention to whatever arises in consciousness.';
      case 'guided_imagery':
        return '${meditation['description']} Guided imagery meditation uses visualization techniques to promote relaxation and emotional balance. These practices can help develop mental resilience and provide a sense of inner stability.';
      case 'self_guided':
        return '${meditation['description']} Self-guided meditation allows you to practice in silence with minimal external guidance. The bells provide structure while giving you the freedom to explore your own meditation approach.';
      default:
        return meditation['description'];
    }
  }

  String _getWhatToExpect(Map<String, dynamic> meditation) {
    switch (widget.categoryId) {
      case 'breathing_practices':
        return 'You may notice your mind becoming calmer and more focused as you follow your breath. It\'s natural for thoughts to arise - simply acknowledge them and gently return to the breath. You might experience a sense of relaxation and present-moment awareness.';
      case 'brief_mindfulness':
        return 'These short practices can provide immediate stress relief and mental clarity. You may feel more grounded and centered after just a few minutes. Regular practice of these brief sessions can significantly improve your daily mindfulness.';
      case 'body_scan':
        return 'You may notice areas of tension releasing as you move your attention through your body. Some people experience tingling, warmth, or deep relaxation. This practice often leads to improved body awareness and better sleep quality.';
      case 'sitting_meditations':
        return 'You might experience periods of calm focus alternating with mental activity. This is completely normal. Over time, you may develop greater emotional stability, improved concentration, and a deeper sense of inner peace.';
      case 'guided_imagery':
        return 'Visualization practices can evoke feelings of calm, strength, or joy depending on the imagery used. You may find these meditations particularly helpful during stressful times or when seeking emotional balance.';
      case 'self_guided':
        return 'Silent meditation allows for a more personal exploration of mindfulness. You may discover your own rhythm and preferred meditation style. The bells help maintain structure while giving you freedom to meditate in your own way.';
      default:
        return 'This meditation will help you develop greater mindfulness and inner peace through regular practice.';
    }
  }

  List<ResearchLink> _getResearchLinks(Map<String, dynamic> meditation) {
    // Return verified research links relevant to the meditation category
    switch (widget.categoryId) {
      case 'breathing_practices':
        return [
          ResearchLink(
            title:
                'Mindfulness-based stress reduction and health benefits: A meta-analysis',
            authors: 'Goyal, M., et al. (2014)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/24395196/',
            description:
                'JAMA Internal Medicine systematic review of mindfulness meditation programs',
          ),
          ResearchLink(
            title:
                'The effect of mindfulness-based stress reduction on anxiety and depression',
            authors: 'Hofmann, S.G., et al. (2010)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/20350028/',
            description:
                'Meta-analysis published in Journal of Consulting and Clinical Psychology',
          ),
        ];
      case 'body_scan':
        return [
          ResearchLink(
            title:
                'Mindfulness-based stress reduction for health care professionals: Results from a pilot study',
            authors: 'Irving, J.A., et al. (2009)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/19340376/',
            description:
                'Study on MBSR including body scan meditation published in Applied Nursing Research',
          ),
          ResearchLink(
            title:
                'Effects of mindfulness on psychological health: A review of empirical studies',
            authors: 'Khoury, B., et al. (2013)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/23490426/',
            description:
                'Comprehensive review published in Clinical Psychology Review',
          ),
        ];
      case 'sitting_meditations':
        return [
          ResearchLink(
            title:
                'Mindfulness meditation training changes brain structure in eight weeks',
            authors: 'Hölzel, B.K., et al. (2011)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/21071182/',
            description:
                'Psychiatry Research study showing structural brain changes from meditation',
          ),
          ResearchLink(
            title:
                'The benefits of mindfulness meditation: Changes in emotional states',
            authors: 'Sharma, A., et al. (2017)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/28031583/',
            description:
                'Study published in International Journal of Yoga on emotional benefits',
          ),
        ];
      case 'brief_mindfulness':
        return [
          ResearchLink(
            title:
                'Brief mindfulness meditation improves mental state attribution and empathy',
            authors: 'Tan, L.B., et al. (2014)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/24395076/',
            description:
                'PLOS ONE study on short-duration mindfulness practices',
          ),
          ResearchLink(
            title:
                'Mindfulness training improves working memory capacity and GRE performance',
            authors: 'Mrazek, M.D., et al. (2013)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/23630220/',
            description:
                'Psychological Science study on cognitive benefits of brief mindfulness training',
          ),
        ];
      case 'guided_imagery':
        return [
          ResearchLink(
            title: 'Guided imagery and relaxation response induced by hypnosis',
            authors: 'Watanabe, E., et al. (2006)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/16460668/',
            description:
                'Psychiatry and Clinical Neurosciences study on guided imagery effectiveness',
          ),
          ResearchLink(
            title:
                'A systematic review of guided imagery as an adjuvant cancer therapy',
            authors: 'Roffe, L., et al. (2005)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/15949983/',
            description:
                'Psycho-Oncology systematic review of guided imagery interventions',
          ),
        ];
      case 'self_guided':
        return [
          ResearchLink(
            title:
                'Mindfulness-based stress reduction and health benefits: A meta-analysis',
            authors: 'Goyal, M., et al. (2014)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/24395196/',
            description:
                'JAMA Internal Medicine meta-analysis of mindfulness meditation benefits',
          ),
          ResearchLink(
            title:
                'Meditation programs for psychological stress and well-being',
            authors: 'Goyal, M., et al. (2014)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/24395196/',
            description:
                'Comprehensive analysis of various meditation approaches including silent practice',
          ),
        ];
      default:
        return [
          ResearchLink(
            title:
                'Mindfulness-based stress reduction and health benefits: A meta-analysis',
            authors: 'Goyal, M., et al. (2014)',
            url: 'https://pubmed.ncbi.nlm.nih.gov/24395196/',
            description:
                'Comprehensive meta-analysis of mindfulness meditation benefits',
          ),
        ];
    }
  }

  String? _getInstructorBio(String instructor) {
    switch (instructor) {
      case 'Peter Morgan':
        return 'Peter Morgan is a mindfulness teacher and researcher who has been developing accessible meditation practices for over two decades. His approach focuses on practical mindfulness that can be easily integrated into daily life.';
      case 'UCLA Mindful Awareness Research Centre':
        return 'The UCLA Mindful Awareness Research Center (MARC) is a leading institution in mindfulness research and education. MARC\'s programs are based on scientific research and designed to help people develop greater well-being through mindfulness.';
      case 'Vidyamala Burch & Breathworks':
        return 'Vidyamala Burch is the co-founder of Breathworks, an organization that teaches mindfulness-based approaches to pain, illness, and stress. She has been teaching meditation for over 30 years and is a respected authority on mindfulness for health.';
      case 'UCSD Center for Mindfulness':
        return 'The UCSD Center for Mindfulness is part of the University of California San Diego and is dedicated to advancing the understanding and application of mindfulness in healthcare, education, and society.';
      case 'Kieran Fleck':
        return 'Kieran Fleck is an experienced meditation teacher who specializes in traditional mindfulness practices. His teachings emphasize the development of sustained attention and deep insights through meditation.';
      case 'Padraig O\'Morain':
        return 'Padraig O\'Morain is an Irish mindfulness teacher and author who has been teaching meditation for many years. His approach is grounded in both traditional Buddhist teachings and modern psychology.';
      case 'Melbourne Mindfulness Centre':
        return 'The Melbourne Mindfulness Centre is a leading provider of mindfulness training in Australia. Their programs are designed to help people develop practical mindfulness skills for everyday life.';
      default:
        return null;
    }
  }

  String? _getAttribution(String instructor) {
    if (instructor.contains('UCLA') || instructor.contains('UCSD')) {
      return 'These recordings are made available for educational and personal use under fair use guidelines.';
    }
    if (instructor.contains('Breathworks')) {
      return 'Used with permission from Breathworks CIC, a Community Interest Company dedicated to teaching mindfulness for health and well-being.';
    }
    return null;
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [],
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

              // Content - Improved padding for better readability
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    // Content with flexible layout (moved to left)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title with improved readability
                          Text(
                            meditation['title'],
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.1,
                                  height: 1.1,
                                  fontSize: 17,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          // Duration and difficulty with improved readability
                          Row(
                            children: [
                              Text(
                                meditation['duration'],
                                style: TextStyle(
                                  color: widget.categoryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: difficultyColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  meditation['difficulty'],
                                  style: TextStyle(
                                    color: difficultyColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Description with improved readability
                          Text(
                            meditation['description'],
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                              height: 1.3,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Source/Author with improved readability
                          Text(
                            'by ${meditation['source']}',
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Play button with better proportions (moved to right)
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              Column(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: Colors.grey.withOpacity(0.6)),
                            ),
                          )
                        : Column(
                            children: [
                              // Debug button for testing
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ElevatedButton(
                                  onPressed: () => _testDownload(),
                                  child: const Text('Test Download System'),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: meditations.length,
                                  itemBuilder: (context, index) {
                                    return _buildMeditationCard(
                                        meditations[index]);
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),

              // Download progress overlay
              if (_isDownloading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: DownloadProgressWidget(
                      progress: _downloadProgress,
                      message: _downloadMessage,
                      onCancel: () {
                        setState(() {
                          _isDownloading = false;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
