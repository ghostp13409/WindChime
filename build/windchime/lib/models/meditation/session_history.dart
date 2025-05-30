class SessionHistory {
  int? id;
  final DateTime date;
  final int duration;
  final String? meditationType;

  SessionHistory({
    this.id,
    required this.date,
    required this.duration,
    this.meditationType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'duration': duration,
      'meditation_type': meditationType,
    };
  }

  factory SessionHistory.fromMap(Map<String, dynamic> map) {
    return SessionHistory(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      duration: map['duration'] as int,
      meditationType: map['meditation_type'] as String?,
    );
  }

  @override
  String toString() {
    return 'SessionHistory{id: $id, date: $date, duration: $duration, meditationType: $meditationType}';
  }
}
