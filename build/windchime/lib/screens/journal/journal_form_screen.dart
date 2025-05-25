import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:windchime/data/repositories/journal_repository.dart';
import 'package:windchime/models/journal/journal_entry.dart';
import 'package:windchime/models/journal/mood_data.dart';
import 'package:windchime/data/db_helper.dart';
import 'package:windchime/providers/theme_provider.dart';

class JournalFormScreen extends StatefulWidget {
  final JournalEntry? entry;

  const JournalFormScreen({super.key, this.entry});

  @override
  State<JournalFormScreen> createState() => _JournalFormScreenState();
}

class _JournalFormScreenState extends State<JournalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = JournalRepository(DbHelper.dbHero);
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _selectedMood;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController =
        TextEditingController(text: widget.entry?.content ?? '');
    _selectedMood = widget.entry?.mood;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });

      try {
        final entry = JournalEntry(
          id: widget.entry?.id,
          title: _titleController.text,
          content: _contentController.text,
          dateCreated: widget.entry?.dateCreated ?? DateTime.now(),
          mood: _selectedMood,
        );

        if (widget.entry == null) {
          await _repository.insertEntry(entry);
        } else {
          await _repository.updateEntry(entry);
        }

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to save entry: ${e.toString()}';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  Widget _buildMoodSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: Moods.all.length,
          itemBuilder: (context, index) {
            final mood = Moods.all[index];
            final isSelected = _selectedMood?.startsWith(mood.emoji) ?? false;
            final bgColor = isSelected
                ? (isDarkMode ? mood.darkColor : mood.color)
                : (isDarkMode ? Colors.grey[800] : Colors.grey[200]);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSaving
                    ? null
                    : () {
                        setState(() {
                          _selectedMood =
                              isSelected ? null : '${mood.emoji} ${mood.label}';
                        });
                      },
                borderRadius: BorderRadius.circular(12),
                child: Ink(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: (isDarkMode ? mood.color : mood.darkColor)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                    ],
                    border: Border.all(
                      color: isSelected
                          ? (isDarkMode ? mood.color : mood.darkColor)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mood.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? 'New Entry' : 'Edit Entry'),
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveEntry,
            ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    enabled: !_isSaving,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.grey[900] : Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    enabled: !_isSaving,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Content',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.grey[900] : Colors.grey[50],
                    ),
                    maxLines: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some content';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildMoodSelector(isDarkMode),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if (_errorMessage != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
