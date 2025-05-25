import 'package:flutter/material.dart';

enum HabitFrequency { hourly, daily, everyOtherDay, weekly, monthly }

extension HabitFrequencyExtension on HabitFrequency {
  String get displayName {
    switch (this) {
      case HabitFrequency.hourly:
        return 'Every Hour';
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.everyOtherDay:
        return 'Every Other Day';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
    }
  }
}

class HabitReminder {
  final Duration aheadOfTime;
  final TimeOfDay time;

  HabitReminder({
    required this.aheadOfTime,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'aheadOfTime': aheadOfTime.inMinutes,
      'time': '${time.hour}:${time.minute}',
    };
  }

  factory HabitReminder.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return HabitReminder(
      aheadOfTime: Duration(minutes: json['aheadOfTime']),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
    );
  }
}

class Habit {
  final String id;
  final String title;
  final bool hasTimer;
  final int? durationInMinutes;
  int streak;
  final HabitFrequency frequency;
  bool isCompleted;
  final DateTime createdAt;
  final DateTime startDate;
  DateTime? lastCompletedAt;
  HabitReminder? reminder;
  final Color color;
  DateTime? timerStartTime;
  bool isTimerRunning;

  Habit({
    String? id,
    required this.title,
    this.hasTimer = false,
    this.durationInMinutes,
    this.streak = 0,
    required this.frequency,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? startDate,
    this.lastCompletedAt,
    this.reminder,
    this.color = Colors.blue,
    this.timerStartTime,
    this.isTimerRunning = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now(),
        startDate = startDate ?? DateTime.now();

  // Copy with method for updating habit properties
  Habit copyWith({
    String? title,
    bool? hasTimer,
    int? durationInMinutes,
    int? streak,
    HabitFrequency? frequency,
    bool? isCompleted,
    DateTime? startDate,
    DateTime? lastCompletedAt,
    HabitReminder? reminder,
    Color? color,
    DateTime? timerStartTime,
    bool? isTimerRunning,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      hasTimer: hasTimer ?? this.hasTimer,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      streak: streak ?? this.streak,
      frequency: frequency ?? this.frequency,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      startDate: startDate ?? this.startDate,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      reminder: reminder ?? this.reminder,
      color: color ?? this.color,
      timerStartTime: timerStartTime ?? this.timerStartTime,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
    );
  }

  // Method to mark habit as complete
  void markAsComplete() {
    final now = DateTime.now();
    if (!isCompleted) {
      isCompleted = true;
      lastCompletedAt = now;
      streak++;
    }
  }

  // Method to mark habit as incomplete
  void markAsIncomplete() {
    if (isCompleted) {
      isCompleted = false;
      if (streak > 0) streak--;
    }
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'hasTimer': hasTimer,
      'durationInMinutes': durationInMinutes,
      'streak': streak,
      'frequency': frequency.index,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      'reminder': reminder?.toJson(),
      'color': color.value,
      'timerStartTime': timerStartTime?.toIso8601String(),
      'isTimerRunning': isTimerRunning,
    };
  }

  // JSON deserialization
  factory Habit.fromJson(Map<String, dynamic> json) {
    HabitReminder? reminder;
    if (json['reminder'] != null) {
      reminder = HabitReminder.fromJson(json['reminder']);
    }

    return Habit(
      id: json['id'],
      title: json['title'],
      hasTimer: json['hasTimer'] ?? false,
      durationInMinutes: json['durationInMinutes'],
      streak: json['streak'],
      frequency: HabitFrequency.values[json['frequency']],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
      startDate: DateTime.parse(json['startDate']),
      lastCompletedAt: json['lastCompletedAt'] != null
          ? DateTime.parse(json['lastCompletedAt'])
          : null,
      reminder: reminder,
      color: Color(json['color']),
      timerStartTime: json['timerStartTime'] != null
          ? DateTime.parse(json['timerStartTime'])
          : null,
      isTimerRunning: json['isTimerRunning'] ?? false,
    );
  }
}
