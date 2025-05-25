import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prog2435_final_project_app/screens/todo/add_todo.dart';
import 'package:prog2435_final_project_app/services/utils/sound_utils.dart';
import 'package:prog2435_final_project_app/widgets/todo/taskItem_widget.dart';
import '../../models/todo/todo_models.dart';
import 'package:prog2435_final_project_app/data/repositories/todo_repository.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _filters = [
    {'name': 'All', 'color': Color(0xFF534AFF)},
    {'name': 'Personal', 'color': Color(0xFF4A90E2)},
    {'name': 'School', 'color': Color(0xFF2ECC71)},
    {'name': 'Work', 'color': Color(0xFFE74C3C)},
  ];

  List<Task> _taskList = [];
  List<Task> _filteredTasks = [];
  String _selectedFilter = 'All';
  String? _searchQuery;
  late AnimationController _fabController;
  final TextEditingController _searchController = TextEditingController();
  final TodoRepository _todoRepository = TodoRepository();

  double get _completionPercentage {
    if (_taskList.isEmpty) return 0;
    return _taskList.where((task) => task.isComplete).length / _taskList.length;
  }

  void _loadTasks() async {
    try {
      final tasks = await _todoRepository.getAllTasks();
      setState(() {
        _taskList = tasks;
        _applyFilters();
      });
    } catch (e) {
      print('Error loading tasks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading tasks'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _applyFilters() {
    var filtered = _taskList;

    // Apply category filter
    if (_selectedFilter != 'All') {
      filtered = filtered
          .where((task) =>
              task.category.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }

    // Apply search filter
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filtered = filtered
          .where((task) =>
              task.taskText.toLowerCase().contains(_searchQuery!.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredTasks = filtered;
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
      _searchController.clear();
      _searchQuery = null;
      _applyFilters();
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredTasks = _taskList;
    _loadTasks();
    _fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
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
                              'TASKS',
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
                                '${_taskList.length}',
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
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _completionPercentage,
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
                          '${_taskList.where((task) => task.isComplete).length} completed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_taskList.where((task) => !task.isComplete).length} remaining',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      icon: Icon(Icons.search, color: theme.primaryColor),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter['name'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(filter['name']),
                          onSelected: (bool selected) {
                            HapticFeedback.selectionClick();
                            _onFilterSelected(filter['name']);
                          },
                          backgroundColor: filter['color'].withOpacity(0.1),
                          selectedColor: filter['color'].withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? filter['color']
                                : theme.textTheme.bodyLarge?.color,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Task List
          Expanded(
            child: _filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: theme.primaryColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks here!',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task =
                          _filteredTasks[_filteredTasks.length - 1 - index];
                      return TaskItem(
                        key: ValueKey(task.id),
                        task: task,
                        onTaskChanged: (task) {
                          HapticFeedback.lightImpact();
                          handleTaskChange(task);
                        },
                        onDeleteItem: (id) {
                          HapticFeedback.vibrate();
                          handleDelete(id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: MouseRegion(
        onEnter: (_) => _fabController.forward(),
        onExit: (_) => _fabController.reverse(),
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.1).animate(
            CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withBlue(
                    (theme.primaryColor.blue + 40).clamp(0, 255),
                  ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () async {
                playSound('todo/sounds/click.mp3');
                HapticFeedback.mediumImpact();
                final Task? newTask = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTodoFormScreen(),
                  ),
                );

                if (newTask != null) {
                  await _todoRepository.insert(newTask);
                  _loadTasks();
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: Icon(
                Icons.add_task_rounded,
                size: 24.0,
              ),
              label: Text(
                'Add Task',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handleTaskChange(Task task) async {
    task.isComplete = !task.isComplete;
    await _todoRepository.update(task);
    _loadTasks();
  }

  void handleDelete(int id) async {
    await _todoRepository.delete(id);
    _loadTasks();
  }
}
