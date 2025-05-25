import 'package:flutter/material.dart';
import 'package:prog2435_final_project_app/models/todo/todo_models.dart';
import 'package:prog2435_final_project_app/services/utils/sound_utils.dart';

class TaskItem extends StatefulWidget {
  const TaskItem({
    super.key,
    required this.task,
    required this.onTaskChanged,
    required this.onDeleteItem,
  });

  final Task task;
  final Function(Task) onTaskChanged;
  final Function(int) onDeleteItem;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  Color _getCategoryColor() {
    switch (widget.task.category.toLowerCase()) {
      case 'personal':
        return Color(0xFF29ABE2); // Vibrant blue
      case 'school':
        return Color(0xFF27AE60); // Vibrant green
      case 'work':
        return Color(0xFFC0392B); // Vibrant red
      default:
        return Color(0xFF7F8C8D); // Darker grey
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _controller.forward().then((_) {
              _controller.reverse();
            });
            widget.onTaskChanged(widget.task);
            if (widget.task.isComplete) {
              playSound('todo/sounds/done.mp3');
            } else {
              playSound('todo/sounds/click.mp3');
            }
          },
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        categoryColor.withOpacity(0.2),
                        categoryColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: categoryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Checkbox area
                      Container(
                        margin: EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: widget.task.isComplete
                              ? null
                              : Border.all(color: categoryColor, width: 2),
                          color: widget.task.isComplete
                              ? categoryColor
                              : Colors.transparent,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: widget.task.isComplete
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : SizedBox(width: 16, height: 16),
                        ),
                      ),

                      // Task text and category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.task.taskText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    decoration: widget.task.isComplete
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: widget.task.isComplete
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color
                                            ?.withOpacity(0.6)
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                  ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.task.category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delete button
                      IconButton(
                        onPressed: () {
                          if (widget.task.id != null) {
                            widget.onDeleteItem(widget.task.id!);
                            playSound('todo/sounds/delete.mp3');
                          }
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
