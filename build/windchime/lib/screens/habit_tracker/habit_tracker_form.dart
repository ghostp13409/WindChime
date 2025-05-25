import 'package:flutter/material.dart';
import '../../models/habit/habit.dart';

class HabitTrackerForm extends StatefulWidget {
  final Habit? habit;

  const HabitTrackerForm({super.key, this.habit});

  @override
  _HabitTrackerFormState createState() => _HabitTrackerFormState();
}

class _QuickTimeButton extends StatelessWidget {
  final int duration;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _QuickTimeButton({
    required this.duration,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.primaryColor.withOpacity(0.1)
              : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? theme.primaryColor
                : theme.primaryColor.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          '${duration}m',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: selected ? theme.primaryColor : theme.colorScheme.onSurface,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _HabitTrackerFormState extends State<HabitTrackerForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _customDurationController;
  late HabitFrequency _selectedFrequency;
  late DateTime _selectedStartDate;
  TimeOfDay? _selectedReminderTime;
  int _selectedReminderAheadMinutes = 15; // Default 15 minutes ahead
  Color _selectedColor = Colors.blue;
  bool _hasTimer = false;
  int _durationInMinutes = 30; // Default 30 minutes

  final List<Color> _predefinedColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    _customDurationController = TextEditingController(
        text: widget.habit?.durationInMinutes?.toString() ?? '30');
    _selectedFrequency = widget.habit?.frequency ?? HabitFrequency.daily;
    _selectedStartDate = widget.habit?.startDate ?? DateTime.now();
    if (widget.habit?.reminder != null) {
      _selectedReminderTime = widget.habit!.reminder!.time;
      _selectedReminderAheadMinutes =
          widget.habit!.reminder!.aheadOfTime.inMinutes;
    }
    _selectedColor = widget.habit?.color ?? Colors.blue;
    _hasTimer = widget.habit?.hasTimer ?? false;
    _durationInMinutes = widget.habit?.durationInMinutes ?? 30;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          'Select a Color',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
        ),
        children: _predefinedColors.map((color) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => _selectedColor = color);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color,
                  width: _selectedColor == color ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _getColorName(color),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: _selectedColor == color
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.red) return 'Red';
    if (color == Colors.green) return 'Green';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.teal) return 'Teal';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.indigo) return 'Indigo';
    if (color == Colors.cyan) return 'Cyan';
    if (color == Colors.amber) return 'Amber';
    return 'Color';
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedReminderTime = picked);
    }
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        id: widget.habit?.id,
        title: _titleController.text,
        hasTimer: _hasTimer,
        durationInMinutes: _hasTimer ? _durationInMinutes : null,
        frequency: _selectedFrequency,
        streak: widget.habit?.streak ?? 0,
        reminder: _selectedReminderTime != null
            ? HabitReminder(
                time: _selectedReminderTime!,
                aheadOfTime: Duration(minutes: _selectedReminderAheadMinutes),
              )
            : null,
        color: _selectedColor,
        startDate: _selectedStartDate,
        isCompleted: widget.habit?.isCompleted ?? false,
        lastCompletedAt: widget.habit?.lastCompletedAt,
      );

      Navigator.of(context).pop(habit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.habit == null ? 'Create Habit' : 'Edit Habit',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save'),
              onPressed: _saveHabit,
              style: TextButton.styleFrom(
                foregroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextFormField(
                  controller: _titleController,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Habit Title',
                    hintText: 'Enter your habit name',
                    prefixIcon: const Icon(Icons.edit_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            color: theme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Timer Settings',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(
                          'Use Timer',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          _hasTimer
                              ? 'Timer will run for $_durationInMinutes minutes'
                              : 'Manual completion',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        value: _hasTimer,
                        onChanged: (bool value) {
                          setState(() {
                            _hasTimer = value;
                          });
                        },
                        activeColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      if (_hasTimer) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duration',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            theme.primaryColor.withOpacity(0.2),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove_circle_outline,
                                            color: theme.primaryColor,
                                          ),
                                          onPressed: () {
                                            if (_durationInMinutes > 5) {
                                              setState(() {
                                                _durationInMinutes -= 5;
                                                _customDurationController.text =
                                                    _durationInMinutes
                                                        .toString();
                                              });
                                            }
                                          },
                                        ),
                                        Text(
                                          '$_durationInMinutes min',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            color: theme.primaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _durationInMinutes += 5;
                                              _customDurationController.text =
                                                  _durationInMinutes.toString();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            theme.primaryColor.withOpacity(0.2),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: TextFormField(
                                      controller: _customDurationController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Custom Duration (minutes)',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      onChanged: (value) {
                                        final duration = int.tryParse(value);
                                        if (duration != null && duration > 0) {
                                          setState(() {
                                            _durationInMinutes = duration;
                                          });
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a duration';
                                        }
                                        final duration = int.tryParse(value);
                                        if (duration == null || duration <= 0) {
                                          return 'Please enter a valid duration';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _QuickTimeButton(
                                    duration: 15,
                                    selected: _durationInMinutes == 15,
                                    onTap: () => setState(() {
                                      _durationInMinutes = 15;
                                      _customDurationController.text = '15';
                                    }),
                                    theme: theme,
                                  ),
                                  _QuickTimeButton(
                                    duration: 30,
                                    selected: _durationInMinutes == 30,
                                    onTap: () => setState(() {
                                      _durationInMinutes = 30;
                                      _customDurationController.text = '30';
                                    }),
                                    theme: theme,
                                  ),
                                  _QuickTimeButton(
                                    duration: 45,
                                    selected: _durationInMinutes == 45,
                                    onTap: () => setState(() {
                                      _durationInMinutes = 45;
                                      _customDurationController.text = '45';
                                    }),
                                    theme: theme,
                                  ),
                                  _QuickTimeButton(
                                    duration: 60,
                                    selected: _durationInMinutes == 60,
                                    onTap: () => setState(() {
                                      _durationInMinutes = 60;
                                      _customDurationController.text = '60';
                                    }),
                                    theme: theme,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.repeat_rounded,
                            color: Colors.purple,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Frequency',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Start Date',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          '${_selectedStartDate.year}-${_selectedStartDate.month.toString().padLeft(2, '0')}-${_selectedStartDate.day.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: TextButton.icon(
                          icon: Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.purple,
                            size: 20,
                          ),
                          label: Text(
                            'Change',
                            style: TextStyle(
                              color: Colors.purple,
                            ),
                          ),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedStartDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedStartDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: HabitFrequency.values.map((frequency) {
                          final isSelected = frequency == _selectedFrequency;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedFrequency = frequency;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.purple.withOpacity(0.1)
                                    : theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.purple
                                      : Colors.purple.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.purple,
                                        size: 16,
                                      ),
                                    ),
                                  Text(
                                    frequency.displayName,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: isSelected
                                          ? Colors.purple
                                          : theme.colorScheme.onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_rounded,
                            color: Colors.orange,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reminder Settings',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(
                          'Enable Reminder',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        value: _selectedReminderTime != null,
                        onChanged: (bool value) {
                          setState(() {
                            if (value) {
                              _selectedReminderTime = TimeOfDay.now();
                            } else {
                              _selectedReminderTime = null;
                            }
                          });
                        },
                        activeColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedReminderTime != null)
                        Container(
                          decoration: BoxDecoration(
                            color: theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  'Reminder Time',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  _selectedReminderTime!.format(context),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton.icon(
                                      icon: Icon(
                                        Icons.access_time_rounded,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      label: Text(
                                        'Change',
                                        style: TextStyle(
                                          color: Colors.orange,
                                        ),
                                      ),
                                      onPressed: () => _selectTime(context),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: Colors.orange.withOpacity(0.2),
                              ),
                              ListTile(
                                title: Text(
                                  'Notify Before',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Wrap(
                                    spacing: 8,
                                    children:
                                        [5, 10, 15, 30, 60].map((minutes) {
                                      final isSelected =
                                          _selectedReminderAheadMinutes ==
                                              minutes;
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedReminderAheadMinutes =
                                                minutes;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.orange.withOpacity(0.1)
                                                : null,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.orange
                                                  : Colors.orange
                                                      .withOpacity(0.3),
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: Text(
                                            '$minutes min',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: isSelected
                                                  ? Colors.orange
                                                  : theme.colorScheme.onSurface,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _selectedColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.palette_rounded,
                            color: _selectedColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Habit Color',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: _showColorPicker,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _selectedColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor.withOpacity(0.3),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _selectedColor.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Tap to change color',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
