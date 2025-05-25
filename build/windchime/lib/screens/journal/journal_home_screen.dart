import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:prog2435_final_project_app/data/repositories/journal_repository.dart';
import 'package:prog2435_final_project_app/models/journal/journal_entry.dart';
import 'package:prog2435_final_project_app/models/journal/mood_data.dart';
import 'package:prog2435_final_project_app/data/db_helper.dart';
import 'package:prog2435_final_project_app/providers/theme_provider.dart';
import 'package:prog2435_final_project_app/screens/journal/journal_form_screen.dart';
import 'package:prog2435_final_project_app/screens/journal/journal_detail_screen.dart';
import 'package:flutter/services.dart';

class JournalHomeScreen extends StatefulWidget {
  const JournalHomeScreen({super.key});

  @override
  State<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends State<JournalHomeScreen> {
  final _repository = JournalRepository(DbHelper.dbHero);
  final ValueNotifier<bool> _refreshTrigger = ValueNotifier<bool>(false);
  String? _selectedMoodFilter;

  Future<void> _refreshList() async {
    _refreshTrigger.value = !_refreshTrigger.value;
  }

  void _navigateToNewEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JournalFormScreen(),
      ),
    ).then((_) => _refreshList());
  }

  List<JournalEntry> _filterEntries(List<JournalEntry> entries) {
    if (_selectedMoodFilter == null) return entries;
    return entries
        .where((entry) => entry.mood?.contains(_selectedMoodFilter!) ?? false)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkTheme;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
            HapticFeedback.lightImpact();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Journal',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Express yourself freely',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _navigateToNewEntry,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.edit_note,
                                  size: 28,
                                  color: textColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedMoodFilter = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedMoodFilter == null
                                          ? (isDarkMode
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.black.withOpacity(0.1))
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: (isDarkMode
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      'All',
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ...Moods.all.map((mood) {
                              final isSelected =
                                  _selectedMoodFilter == mood.emoji;
                              return Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedMoodFilter =
                                            isSelected ? null : mood.emoji;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isDarkMode
                                                    ? mood.darkColor
                                                    : mood.color)
                                                .withOpacity(
                                                    isDarkMode ? 0.3 : 0.2)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: (isDarkMode
                                                  ? mood.color
                                                  : mood.darkColor)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(mood.emoji,
                                              style: const TextStyle(
                                                  fontSize: 20)),
                                          const SizedBox(width: 8),
                                          Text(
                                            mood.label,
                                            style: TextStyle(
                                              color: textColor.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: ValueListenableBuilder<bool>(
            valueListenable: _refreshTrigger,
            builder: (context, _, __) => FutureBuilder<List<JournalEntry>>(
              future: _repository.getAllEntries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: isDarkMode ? Colors.red[300] : Colors.red[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                isDarkMode ? Colors.red[300] : Colors.red[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshList,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final allEntries = snapshot.data ?? [];
                final entries = _filterEntries(allEntries);

                if (entries.isEmpty) {
                  if (_selectedMoodFilter != null && allEntries.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mood_bad,
                            size: 64,
                            color: isDarkMode ? Colors.white24 : Colors.black26,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No entries with this mood',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkMode ? Colors.white54 : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try selecting a different mood',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isDarkMode ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book,
                          size: 64,
                          color: isDarkMode ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start Your Journey',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Write your first journal entry',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshList,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final moodData = Moods.fromEmoji(entry.mood);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    JournalDetailScreen(entry: entry),
                              ),
                            ).then((_) => _refreshList());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: moodData != null
                                  ? Border.all(
                                      color: (isDarkMode
                                              ? moodData.color
                                              : moodData.darkColor)
                                          .withOpacity(0.3),
                                    )
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (entry.mood != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: moodData != null
                                              ? (isDarkMode
                                                      ? moodData.darkColor
                                                      : moodData.color)
                                                  .withOpacity(
                                                      isDarkMode ? 0.2 : 0.1)
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          entry.mood!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: textColor.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: textColor.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  DateFormat('MMMM d, y')
                                      .format(entry.dateCreated),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textColor.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}
