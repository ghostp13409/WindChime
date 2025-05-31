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
