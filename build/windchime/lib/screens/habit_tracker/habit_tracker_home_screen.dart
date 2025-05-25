import 'package:flutter/material.dart';
import 'package:prog2435_final_project_app/models/habit/habit.dart';
import 'package:prog2435_final_project_app/screens/habit_tracker/habit_tracker_form.dart';
import 'package:prog2435_final_project_app/widgets/habit_tracker/habit_card.dart';
import 'package:prog2435_final_project_app/services/notification_service.dart';
import 'package:prog2435_final_project_app/data/repositories/habit_repository.dart';
import 'package:flutter/services.dart'; // Import for haptics

class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  _HabitListScreenState createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  List<Habit> _habits = [];
  final NotificationService _notificationService = NotificationService();
  final HabitRepository _habitRepository = HabitRepository();

  @override
  void initState() {
    super.initState();
    _initializeHabits();
  }

  Future<void> _initializeHabits() async {
    final habits = await _habitRepository.getAllHabits();
    final now = DateTime.now();

    // Process each habit for streak and completion status
    for (final habit in habits) {
      Habit updatedHabit = habit;
      if (habit.lastCompletedAt != null) {
        final timeSinceLastCompletion = now.difference(habit.lastCompletedAt!);
        bool shouldResetCompletion = false;
        bool shouldResetStreak = false;

        switch (habit.frequency) {
          case HabitFrequency.hourly:
            shouldResetCompletion = timeSinceLastCompletion.inHours >= 1;
            shouldResetStreak = timeSinceLastCompletion.inHours > 2;
            break;
          case HabitFrequency.daily:
            shouldResetCompletion = timeSinceLastCompletion.inDays >= 1;
            shouldResetStreak = timeSinceLastCompletion.inHours > 24;
            break;
          case HabitFrequency.everyOtherDay:
            shouldResetCompletion = timeSinceLastCompletion.inDays >= 2;
            shouldResetStreak = timeSinceLastCompletion.inHours > 48;
            break;
          case HabitFrequency.weekly:
            shouldResetCompletion = timeSinceLastCompletion.inDays >= 7;
            shouldResetStreak = timeSinceLastCompletion.inDays > 8;
            break;
          case HabitFrequency.monthly:
            shouldResetCompletion = timeSinceLastCompletion.inDays >= 30;
            shouldResetStreak = timeSinceLastCompletion.inDays > 31;
            break;
        }

        if (shouldResetCompletion) {
          if (shouldResetStreak) {
            updatedHabit = habit.copyWith(
              isCompleted: false,
              streak: 0,
            );
          } else {
            updatedHabit = habit.copyWith(
              isCompleted: false,
            );
          }
          await _habitRepository.update(updatedHabit);
        }
      }

      // Schedule notifications for habits with reminders
      if (updatedHabit.reminder != null) {
        await _notificationService.scheduleHabitReminder(updatedHabit);
      }
    }

    // Reload habits after processing
    final updatedHabits = await _habitRepository.getAllHabits();
    setState(() {
      _habits = updatedHabits;
    });
  }

  Future<void> _addHabit() async {
    HapticFeedback.lightImpact(); // Add haptic feedback
    final result = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(builder: (context) => const HabitTrackerForm()),
    );

    if (result != null) {
      await _habitRepository.insert(result);
      await _initializeHabits();
      if (result.reminder != null) {
        await _notificationService.scheduleHabitReminder(result);
      }
    }
  }

  Future<void> _editHabit(Habit habit) async {
    HapticFeedback.lightImpact(); // Add haptic feedback
    final result = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
        builder: (context) => HabitTrackerForm(habit: habit),
      ),
    );

    if (result != null) {
      await _habitRepository.update(result);
      await _initializeHabits();
      await _notificationService.cancelHabitReminders(habit);
      if (result.reminder != null) {
        await _notificationService.scheduleHabitReminder(result);
      }
    }
  }

  Future<void> _toggleHabitCompletion(Habit habit) async {
    HapticFeedback.selectionClick(); // Add haptic feedback
    Habit updatedHabit;
    if (habit.isCompleted) {
      updatedHabit = habit.copyWith(
        isCompleted: false,
        streak: habit.streak > 0 ? habit.streak - 1 : 0,
        lastCompletedAt: null,
      );
    } else {
      updatedHabit = habit.copyWith(
        isCompleted: true,
        streak: habit.streak + 1,
        lastCompletedAt: DateTime.now(),
      );
    }
    await _habitRepository.update(updatedHabit);
    await _initializeHabits();
  }

  void _deleteHabit(Habit habit) {
    HapticFeedback.vibrate(); // Add haptic feedback
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact(); // Add haptic feedback
              _habitRepository.delete(habit.id).then((_) {
                _notificationService.cancelHabitReminders(habit);
                _initializeHabits();
                Navigator.pop(context);
              });
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact(); // Add haptic feedback
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HABITS',
                              style: TextStyle(
                                fontSize: 14,
                                letterSpacing: 2,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Daily Progress',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.primaryColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                size: 20,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_habits.length}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_habits.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _habits.where((h) => h.isCompleted).length /
                            _habits.length,
                        backgroundColor: Colors.grey[800],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(theme.primaryColor),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_habits.where((h) => h.isCompleted).length} completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${_habits.where((h) => !h.isCompleted).length} remaining',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _habits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_task_rounded,
                            size: 48,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No habits yet',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add a new habit',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _habits.length,
                    itemBuilder: (context, index) {
                      final habit = _habits[index];
                      return SizedBox(
                        width: double.infinity,
                        child: HabitCard(
                          key: ObjectKey(habit),
                          habit: habit,
                          onEdit: _editHabit,
                          onDelete: _deleteHabit,
                          onToggleCompletion: _toggleHabitCompletion,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact(); // Add haptic feedback
          _addHabit();
        },
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
    );
  }
}
