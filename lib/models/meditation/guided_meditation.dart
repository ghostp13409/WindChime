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

class ResearchLink {
  final String title;
  final String url;
  final String? authors;
  final String? description;

  const ResearchLink({
    required this.title,
    required this.url,
    this.authors,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'authors': authors,
      'description': description,
    };
  }

  factory ResearchLink.fromMap(Map<String, dynamic> map) {
    return ResearchLink(
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      authors: map['authors'],
      description: map['description'],
    );
  }
}

class GuidedMeditation {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final String audioPath;
  final int durationSeconds;
  final String instructor;
  final List<String> tags;
  final String? imageUrl;
  final bool isPopular;
  final double rating;
  final int playCount;
  final String? detailedDescription;
  final String? whatToExpect;
  final List<ResearchLink> researchLinks;
  final String? instructorBio;
  final String? attribution;

  const GuidedMeditation({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.audioPath,
    required this.durationSeconds,
    required this.instructor,
    this.tags = const [],
    this.imageUrl,
    this.isPopular = false,
    this.rating = 0.0,
    this.playCount = 0,
    this.detailedDescription,
    this.whatToExpect,
    this.researchLinks = const [],
    this.instructorBio,
    this.attribution,
  });

  // Helper methods
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (seconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  String get shortDescription {
    return description.length > 80
        ? '${description.substring(0, 77)}...'
        : description;
  }

  // Convert to/from map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'audioPath': audioPath,
      'durationSeconds': durationSeconds,
      'instructor': instructor,
      'tags': tags.join(','),
      'imageUrl': imageUrl,
      'isPopular': isPopular ? 1 : 0,
      'rating': rating,
      'playCount': playCount,
      'detailedDescription': detailedDescription,
      'whatToExpect': whatToExpect,
      'researchLinks': researchLinks.map((link) => link.toMap()).toList(),
      'instructorBio': instructorBio,
      'attribution': attribution,
    };
  }

  factory GuidedMeditation.fromMap(Map<String, dynamic> map) {
    return GuidedMeditation(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? '',
      audioPath: map['audioPath'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 0,
      instructor: map['instructor'] ?? '',
      tags: map['tags'] != null ? map['tags'].split(',') : [],
      imageUrl: map['imageUrl'],
      isPopular: map['isPopular'] == 1,
      rating: map['rating']?.toDouble() ?? 0.0,
      playCount: map['playCount'] ?? 0,
      detailedDescription: map['detailedDescription'],
      whatToExpect: map['whatToExpect'],
      researchLinks: map['researchLinks'] != null
          ? (map['researchLinks'] as List)
              .map((link) => ResearchLink.fromMap(link))
              .toList()
          : [],
      instructorBio: map['instructorBio'],
      attribution: map['attribution'],
    );
  }

  // Create a copy with updated values
  GuidedMeditation copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? audioPath,
    int? durationSeconds,
    String? instructor,
    List<String>? tags,
    String? imageUrl,
    bool? isPopular,
    double? rating,
    int? playCount,
    String? detailedDescription,
    String? whatToExpect,
    List<ResearchLink>? researchLinks,
    String? instructorBio,
    String? attribution,
  }) {
    return GuidedMeditation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      audioPath: audioPath ?? this.audioPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      instructor: instructor ?? this.instructor,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      isPopular: isPopular ?? this.isPopular,
      rating: rating ?? this.rating,
      playCount: playCount ?? this.playCount,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      whatToExpect: whatToExpect ?? this.whatToExpect,
      researchLinks: researchLinks ?? this.researchLinks,
      instructorBio: instructorBio ?? this.instructorBio,
      attribution: attribution ?? this.attribution,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuidedMeditation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GuidedMeditation(id: $id, title: $title, duration: $formattedDuration)';
  }
}
