import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:prog2435_final_project_app/data/repositories/journal_repository.dart';
import 'package:prog2435_final_project_app/models/journal/journal_entry.dart';
import 'package:prog2435_final_project_app/models/journal/mood_data.dart';
import 'package:prog2435_final_project_app/data/db_helper.dart';
import 'package:prog2435_final_project_app/providers/theme_provider.dart';
import 'package:prog2435_final_project_app/screens/journal/journal_form_screen.dart';

class JournalDetailScreen extends StatefulWidget {
  final JournalEntry entry;

  const JournalDetailScreen({super.key, required this.entry});

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  final _repository = JournalRepository(DbHelper.dbHero);
  bool _isDeleting = false;

  Future<void> _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      try {
        await _repository.deleteEntry(widget.entry.id!);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting entry: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  Widget _buildMoodChip(MoodData? moodData, bool isDarkMode) {
    if (moodData == null) return const SizedBox.shrink();

    final color = isDarkMode ? moodData.darkColor : moodData.color;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            moodData.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            moodData.label,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            moodData.icon,
            size: 18,
            color: textColor.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkTheme;
    final moodData = Moods.fromEmoji(widget.entry.mood);

    final baseColor = isDarkMode ? const Color(0xFF121212) : Colors.grey[50]!;

    final Color backgroundColor = moodData != null
        ? Color.alphaBlend(
            (isDarkMode ? moodData.darkColor : moodData.color)
                .withOpacity(isDarkMode ? 0.15 : 0.02),
            baseColor,
          )
        : baseColor;

    final contentColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Journal Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isDeleting
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JournalFormScreen(entry: widget.entry),
                      ),
                    ).then((_) => setState(() {}));
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _deleteEntry,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMMM d, y • h:mm a')
                                .format(widget.entry.dateCreated),
                            style: TextStyle(
                              fontSize: 14,
                              color: contentColor.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.entry.title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: contentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.entry.mood != null)
                  _buildMoodChip(moodData, isDarkMode),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? const Color(0xFF252525) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isDarkMode ? Colors.white12 : Colors.black12),
                    ),
                  ),
                  child: Text(
                    widget.entry.content,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: contentColor.withOpacity(isDarkMode ? 0.87 : 0.75),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isDeleting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
