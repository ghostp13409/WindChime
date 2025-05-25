import 'package:flutter/material.dart';
import 'dart:async';
import 'package:prog2435_final_project_app/models/habit/habit.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final Function(Habit) onEdit;
  final Function(Habit) onDelete;
  final Function(Habit) onToggleCompletion;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleCompletion,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  Timer? _timer;
  int _secondsRemaining = 0;
  bool get isTimerRunning => _timer?.isActive ?? false;

  String _getNextOccurrence() {
    final DateTime now = DateTime.now();
    DateTime nextDate;
    String label = 'Next: ';

    if (widget.habit.lastCompletedAt != null && !widget.habit.isCompleted) {
      // Base next date off of last completion
      switch (widget.habit.frequency) {
        case HabitFrequency.hourly:
          nextDate =
              widget.habit.lastCompletedAt!.add(const Duration(hours: 1));
          break;
        case HabitFrequency.daily:
          nextDate = widget.habit.lastCompletedAt!.add(const Duration(days: 1));
          break;
        case HabitFrequency.everyOtherDay:
          nextDate = widget.habit.lastCompletedAt!.add(const Duration(days: 2));
          break;
        case HabitFrequency.weekly:
          nextDate = widget.habit.lastCompletedAt!.add(const Duration(days: 7));
          break;
        case HabitFrequency.monthly:
          nextDate = DateTime(
            widget.habit.lastCompletedAt!.year,
            widget.habit.lastCompletedAt!.month + 1,
            widget.habit.lastCompletedAt!.day,
          );
          break;
      }
    } else {
      // Base next date off of start date
      switch (widget.habit.frequency) {
        case HabitFrequency.hourly:
          nextDate = widget.habit.startDate.add(const Duration(hours: 1));
          break;
        case HabitFrequency.daily:
          nextDate = widget.habit.startDate;
          break;
        case HabitFrequency.everyOtherDay:
          nextDate = widget.habit.startDate.add(const Duration(days: 2));
          break;
        case HabitFrequency.weekly:
          nextDate = widget.habit.startDate.add(const Duration(days: 7));
          break;
        case HabitFrequency.monthly:
          nextDate = DateTime(
            widget.habit.startDate.year,
            widget.habit.startDate.month + 1,
            widget.habit.startDate.day,
          );
          break;
      }
    }

    if (widget.habit.isCompleted) {
      return 'Done today';
    }

    if (nextDate.isBefore(now)) {
      return 'Due now';
    }

    if (nextDate.difference(now).inDays == 0) {
      if (widget.habit.frequency == HabitFrequency.hourly) {
        final minutes = nextDate.difference(now).inMinutes;
        return '$label${minutes}m';
      }
      return '${label}Today';
    } else if (nextDate.difference(now).inDays == 1) {
      return '${label}Tomorrow';
    } else {
      return '${label}in ${nextDate.difference(now).inDays}d';
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.habit.isTimerRunning && widget.habit.timerStartTime != null) {
      final elapsedSeconds =
          DateTime.now().difference(widget.habit.timerStartTime!).inSeconds;
      final totalSeconds = widget.habit.durationInMinutes! * 60;
      _secondsRemaining = totalSeconds - elapsedSeconds;
      if (_secondsRemaining > 0) {
        _startTimer();
      }
    } else if (widget.habit.hasTimer &&
        widget.habit.durationInMinutes != null) {
      _secondsRemaining = widget.habit.durationInMinutes! * 60;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!widget.habit.hasTimer || widget.habit.durationInMinutes == null) {
      return;
    }

    if (_timer?.isActive ?? false) return;

    if (_secondsRemaining <= 0) {
      _secondsRemaining = widget.habit.durationInMinutes! * 60;
    }

    setState(() {
      widget.habit.timerStartTime = DateTime.now();
      widget.habit.isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          widget.habit.isTimerRunning = false;
          widget.onToggleCompletion(widget.habit);
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      widget.habit.isTimerRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = widget.habit.durationInMinutes! * 60;
      widget.habit.isTimerRunning = false;
      widget.habit.timerStartTime = null;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 160,
        maxHeight: 180,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: widget.habit.color.withOpacity(0.1),
          child: InkWell(
            onTap: () {
              if (widget.habit.hasTimer) {
                if (isTimerRunning) {
                  _pauseTimer();
                } else {
                  _startTimer();
                }
              } else {
                widget.onToggleCompletion(widget.habit);
              }
            },
            onLongPress: widget.habit.hasTimer ? _resetTimer : null,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.habit.reminder != null)
                        Icon(
                          Icons.notifications_active,
                          size: 14,
                          color: widget.habit.color,
                        )
                      else
                        const SizedBox(width: 14),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_horiz,
                            color: widget.habit.color, size: 20),
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              widget.onEdit(widget.habit);
                              break;
                            case 'delete':
                              widget.onDelete(widget.habit);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      widget.habit.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.habit.hasTimer) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: widget.habit.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isTimerRunning
                            ? _formatTime(_secondsRemaining)
                            : '${widget.habit.durationInMinutes} min',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.habit.color,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  AnimatedScale(
                    scale: widget.habit.isCompleted ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.habit.streak.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.habit.isCompleted
                                ? widget.habit.color
                                : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '🔥',
                          style: TextStyle(
                            fontSize: 20,
                            color: widget.habit.isCompleted
                                ? Colors.orange
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: widget.habit.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.habit.frequency.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: widget.habit.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.habit.reminder != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.habit.reminder!.time.format(context),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
