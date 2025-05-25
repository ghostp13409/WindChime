class SessionHistory {
  int? id;
  final DateTime date;
  final int duration;

  SessionHistory({
    this.id,
    required this.date,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'duration': duration,
    };
  }

  factory SessionHistory.fromMap(Map<String, dynamic> map) {
    return SessionHistory(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      duration: map['duration'] as int,
    );
  }

  @override
  String toString() {
    return 'SessionHistory{id: $id, date: $date, duration: $duration}';
  }
}
