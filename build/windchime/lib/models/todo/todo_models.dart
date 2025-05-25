class Task {
  int? id;
  String taskText;
  bool isComplete;
  String category;

  Task({
    this.id, // Id is automatically given by the database
    required this.taskText,
    this.isComplete = false,
    required this.category,
  });

  // Convert Task to Map (for Sqflite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskText': taskText,
      'isComplete': isComplete ? 1 : 0, // Store as INTEGER (1 or 0)
      'category': category,
    };
  }

  // Convert Map to Task (from Sqflite)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      taskText: map['taskText'] as String,
      isComplete:
          (map['isComplete'] as int) == 1, // Converts integer to boolean
      category: map['category'] as String,
    );
  }
}
