import 'package:flutter/material.dart';
import '../../models/habit/habit.dart';
import '../db_helper.dart';

class HabitRepository {
  final dbHelper = DbHelper.dbHero;

  Future<int> insert(Habit habit) async {
    return await dbHelper.insertDb(toMap(habit), 'habits');
  }

  Future<List<Habit>> getAllHabits() async {
    final List<Map<String, dynamic>> maps = await dbHelper.readDb('habits');
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  Future<int> update(Habit habit) async {
    return await dbHelper.updateDb(toMap(habit), 'habits');
  }

  Future<int> delete(String id) async {
    return await dbHelper.deleteDb(id, 'habits');
  }

  // Helper method to convert Habit to Map
  Map<String, dynamic> toMap(Habit habit) {
    HabitReminder? reminder = habit.reminder;
    return {
      'id': habit.id,
      'title': habit.title,
      'hasTimer': habit.hasTimer ? 1 : 0,
      'durationInMinutes': habit.durationInMinutes,
      'streak': habit.streak,
      'frequency': habit.frequency.index,
      'isCompleted': habit.isCompleted ? 1 : 0,
      'createdAt': habit.createdAt.toIso8601String(),
      'lastCompletedAt': habit.lastCompletedAt?.toIso8601String(),
      'reminderAheadMinutes': reminder?.aheadOfTime.inMinutes,
      'reminderTime': reminder != null
          ? '${reminder.time.hour}:${reminder.time.minute}'
          : null,
      'color': habit.color.value,
      'timerStartTime': habit.timerStartTime?.toIso8601String(),
      'isTimerRunning': habit.isTimerRunning ? 1 : 0,
    };
  }

  // Helper method to convert Map to Habit
  Habit fromMap(Map<String, dynamic> map) {
    HabitReminder? reminder;
    if (map['reminderTime'] != null && map['reminderAheadMinutes'] != null) {
      final timeParts = (map['reminderTime'] as String).split(':');
      reminder = HabitReminder(
        aheadOfTime: Duration(minutes: map['reminderAheadMinutes'] as int),
        time: TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        ),
      );
    }

    return Habit(
      id: map['id'] as String,
      title: map['title'] as String,
      hasTimer: (map['hasTimer'] as int) == 1,
      durationInMinutes: map['durationInMinutes'] as int?,
      streak: map['streak'] as int,
      frequency: HabitFrequency.values[map['frequency'] as int],
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastCompletedAt: map['lastCompletedAt'] != null
          ? DateTime.parse(map['lastCompletedAt'] as String)
          : null,
      reminder: reminder,
      color: Color(map['color'] as int),
      timerStartTime: map['timerStartTime'] != null
          ? DateTime.parse(map['timerStartTime'] as String)
          : null,
      isTimerRunning: (map['isTimerRunning'] as int) == 1,
    );
  }
}
