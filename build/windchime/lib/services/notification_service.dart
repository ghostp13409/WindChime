import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/habit/habit.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService._();

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(initializationSettings);
    _isInitialized = true;
  }

  Future<void> scheduleHabitReminder(Habit habit) async {
    if (!_isInitialized) await initialize();
    if (habit.reminder == null) return;

    // Cancel any existing notifications for this habit
    await cancelHabitReminders(habit);

    final now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      habit.reminder!.time.hour,
      habit.reminder!.time.minute,
    );

    // If the time has passed for today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Calculate the reminder time with the ahead duration
    scheduledDate = scheduledDate.subtract(habit.reminder!.aheadOfTime);

    // Schedule differently based on frequency
    switch (habit.frequency) {
      case HabitFrequency.daily:
        await _scheduleDaily(habit, scheduledDate);
        break;
      case HabitFrequency.everyOtherDay:
        await _scheduleEveryOtherDay(habit, scheduledDate);
        break;
      case HabitFrequency.weekly:
        await _scheduleWeekly(habit, scheduledDate);
        break;
      case HabitFrequency.monthly:
        await _scheduleMonthly(habit, scheduledDate);
        break;
      case HabitFrequency.hourly:
        await _scheduleHourly(habit);
        break;
    }
  }

  Future<void> _scheduleDaily(Habit habit, DateTime firstTime) async {
    await _notifications.zonedSchedule(
      habit.id.hashCode,
      'Time for ${habit.title}!',
      _getNotificationBody(habit),
      tz.TZDateTime.from(firstTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Notifications for habit reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleEveryOtherDay(Habit habit, DateTime firstTime) async {
    await _notifications.zonedSchedule(
      habit.id.hashCode,
      'Time for ${habit.title}!',
      _getNotificationBody(habit),
      tz.TZDateTime.from(firstTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Notifications for habit reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'every_other_day',
    );
  }

  Future<void> _scheduleWeekly(Habit habit, DateTime firstTime) async {
    await _notifications.zonedSchedule(
      habit.id.hashCode,
      'Time for ${habit.title}!',
      _getNotificationBody(habit),
      tz.TZDateTime.from(firstTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Notifications for habit reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> _scheduleMonthly(Habit habit, DateTime firstTime) async {
    await _notifications.zonedSchedule(
      habit.id.hashCode,
      'Time for ${habit.title}!',
      _getNotificationBody(habit),
      tz.TZDateTime.from(firstTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Notifications for habit reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> _scheduleHourly(Habit habit) async {
    final now = DateTime.now();
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1);

    await _notifications.zonedSchedule(
      habit.id.hashCode,
      'Time for ${habit.title}!',
      _getNotificationBody(habit),
      tz.TZDateTime.from(nextHour, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Notifications for habit reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  String _getNotificationBody(Habit habit) {
    if (habit.hasTimer) {
      return 'Time to start your ${habit.durationInMinutes}-minute ${habit.title.toLowerCase()}';
    }
    return 'Time to do ${habit.title.toLowerCase()}';
  }

  Future<void> cancelHabitReminders(Habit habit) async {
    await _notifications.cancel(habit.id.hashCode);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}
