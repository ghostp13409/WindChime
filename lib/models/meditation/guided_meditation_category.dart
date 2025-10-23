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

class GuidedMeditationCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final String folderPath;
  final int estimatedDuration; // in minutes for display
  final List<String> benefits;

  const GuidedMeditationCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.folderPath,
    required this.estimatedDuration,
    required this.benefits,
  });

  // Pre-defined categories based on research
  static const Map<String, GuidedMeditationCategory> categories = {
    'breathing_practices': GuidedMeditationCategory(
      id: 'breathing_practices',
      name: 'Breathing Practices',
      description:
          'Short mindfulness exercises focusing on breath awareness to bring you into the present moment and develop mindfulness.',
      icon: Icons.air,
      primaryColor: Color(0xFF6B46C1),
      folderPath: 'assets/sounds/meditation/guided/breathing_practices/',
      estimatedDuration: 7, // 3-10 min average
      benefits: [
        'Present moment awareness',
        'Stress reduction',
        'Mindfulness development'
      ],
    ),
    'brief_mindfulness': GuidedMeditationCategory(
      id: 'brief_mindfulness',
      name: 'Brief Mindfulness',
      description:
          'Shorter mindfulness sessions ideal for brief resets during your day through breath, sound, and bodily awareness.',
      icon: Icons.psychology,
      primaryColor: Color(0xFFEA580C),
      folderPath:
          'assets/sounds/meditation/guided/brief_mindfulness_practices/',
      estimatedDuration: 4, // 3-5 min average
      benefits: ['Quick reset', 'Daily grounding', 'Stress relief'],
    ),
    'body_scan': GuidedMeditationCategory(
      id: 'body_scan',
      name: 'Body Scan',
      description:
          'Move your attention through different parts of the body, observing sensations and cultivating present-moment awareness.',
      icon: Icons.self_improvement,
      primaryColor: Color(0xFFDC2626),
      folderPath: 'assets/sounds/meditation/guided/body_scan/',
      estimatedDuration: 20, // 4-47 min average
      benefits: [
        'Body awareness',
        'Physical relaxation',
        'Mind-body connection'
      ],
    ),
    'sitting_meditations': GuidedMeditationCategory(
      id: 'sitting_meditations',
      name: 'Sitting Meditations',
      description:
          'Comprehensive meditation practices centered on breath while inviting awareness of sounds, sensations, thoughts, and emotions.',
      icon: Icons.chair,
      primaryColor: Color(0xFFF59E0B),
      folderPath: 'assets/sounds/meditation/guided/sitting_meditations/',
      estimatedDuration: 15, // 10-21 min average
      benefits: [
        'Deep meditation',
        'Emotional awareness',
        'Thought observation'
      ],
    ),
    'guided_imagery': GuidedMeditationCategory(
      id: 'guided_imagery',
      name: 'Guided Imagery',
      description:
          'Use visualization and imagination to foster calm, resilience, and emotional balance through guided imagery practices.',
      icon: Icons.landscape,
      primaryColor: Color(0xFF7C3AED),
      folderPath: 'assets/sounds/meditation/guided/guided_imagery/',
      estimatedDuration: 8, // 7-8 min average
      benefits: [
        'Visualization skills',
        'Emotional balance',
        'Creative relaxation'
      ],
    ),
    'self_guided': GuidedMeditationCategory(
      id: 'self_guided',
      name: 'Self Guided',
      description:
          'Silent meditation sessions with beginning and ending bells, some include interval bells to structure your practice.',
      icon: Icons.notifications_none,
      primaryColor: Color(0xFF059669),
      folderPath:
          'assets/sounds/meditation/guided/self_guided_mindfulness_exercises/',
      estimatedDuration: 20, // 5-45 min average
      benefits: ['Silent practice', 'Self-direction', 'Deep focus'],
    ),
  };

  // Helper methods
  String getShortDescription() {
    return description.length > 100
        ? '${description.substring(0, 97)}...'
        : description;
  }

  String getDurationText() {
    return '$estimatedDuration min sessions';
  }

  // Convert to/from map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'folderPath': folderPath,
      'estimatedDuration': estimatedDuration,
      'benefits': benefits.join(','),
    };
  }

  factory GuidedMeditationCategory.fromMap(Map<String, dynamic> map) {
    // This would need the icon and color to be stored differently
    // For now, we'll use the predefined categories
    return categories[map['id']] ?? categories['breathing_practices']!;
  }
}
