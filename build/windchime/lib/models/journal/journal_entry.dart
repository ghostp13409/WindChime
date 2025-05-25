class JournalEntry {
  final int? id;
  final String title;
  final String content;
  final DateTime dateCreated;
  final String? mood;

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.dateCreated,
    this.mood,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'dateCreated': dateCreated.toIso8601String(),
      'mood': mood,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      dateCreated: DateTime.parse(map['dateCreated']),
      mood: map['mood'],
    );
  }
}
