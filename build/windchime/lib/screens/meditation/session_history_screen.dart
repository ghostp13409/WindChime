import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:windchime/data/repositories/meditation_repository.dart';
import 'package:windchime/models/meditation/session_history.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  _SessionHistoryScreenState createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  final _meditationRepository = MeditationRepository();
  List<SessionHistory> _sessions = [];
  int _totalSessions = 0;
  int _totalMinutes = 0;
  bool _isLoading = true;

  // Color scheme matching the meditation categories
  static const Color primaryAccent = Color(0xFF8E97FD);
  static const Color secondaryAccent = Color(0xFFF6815B);
  static const Color tertiaryAccent = Color(0xFFFA6E5A);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final sessions = await _meditationRepository.getAllSessions();
    final totalSessions = await _meditationRepository.getTotalSessionsCount();
    final totalMinutes =
        await _meditationRepository.getTotalMeditationMinutes();

    // Sort sessions by date (latest first)
    sessions.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _sessions = sessions;
      _totalSessions = totalSessions;
      _totalMinutes = totalMinutes ~/ 60;
      _isLoading = false;
    });
  }

  Future<void> _deleteSession(SessionHistory session) async {
    HapticFeedback.lightImpact();

    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Session'),
          content: const Text(
              'Are you sure you want to delete this meditation session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: tertiaryAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _meditationRepository.deleteSession(session.id!);
      _loadData();
    }
  }

  // Get meditation type info (icon and color)
  Map<String, dynamic> _getMeditationTypeInfo(String? meditationType) {
    switch (meditationType?.toLowerCase()) {
      case 'demo':
        return {
          'icon': Icons.play_circle_outline,
          'color': const Color(0xFF00C896),
          'name': 'Demo'
        };
      case 'sleep':
        return {
          'icon': Icons.nightlight_round,
          'color': const Color(0xFF8E97FD),
          'name': 'Sleep'
        };
      case 'focus':
        return {
          'icon': Icons.psychology,
          'color': const Color(0xFFF6815B),
          'name': 'Focus'
        };
      case 'anxiety':
        return {
          'icon': Icons.healing,
          'color': const Color(0xFFFA6E5A),
          'name': 'Anxiety'
        };
      case 'happiness':
        return {
          'icon': Icons.self_improvement,
          'color': const Color(0xFFFFCF86),
          'name': 'Happiness'
        };
      default:
        return {
          'icon': Icons.self_improvement,
          'color': primaryAccent,
          'name': 'Meditation'
        };
    }
  }

  // Group sessions by time periods
  Map<String, List<SessionHistory>> _groupSessionsByTime() {
    final Map<String, List<SessionHistory>> grouped = {
      'Today': [],
      'Yesterday': [],
      'Last Week': [],
      'Last Month': [],
      'Earlier This Year': [],
      'Older': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final oneWeekAgo = today.subtract(const Duration(days: 7));
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    final startOfYear = DateTime(now.year, 1, 1);

    for (final session in _sessions) {
      final sessionDate =
          DateTime(session.date.year, session.date.month, session.date.day);

      if (sessionDate == today) {
        grouped['Today']!.add(session);
      } else if (sessionDate == yesterday) {
        grouped['Yesterday']!.add(session);
      } else if (sessionDate.isAfter(oneWeekAgo)) {
        grouped['Last Week']!.add(session);
      } else if (sessionDate.isAfter(oneMonthAgo)) {
        grouped['Last Month']!.add(session);
      } else if (sessionDate.isAfter(startOfYear) ||
          sessionDate.isAtSameMomentAs(startOfYear)) {
        grouped['Earlier This Year']!.add(session);
      } else {
        grouped['Older']!.add(session);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (remainingSeconds == 0) {
      return '$minutes min';
    }
    return '$minutes min $remainingSeconds sec';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);

    if (sessionDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (sessionDate == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, y • h:mm a').format(date);
    }
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            primaryAccent.withOpacity(0.8),
            secondaryAccent.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : primaryAccent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.self_improvement,
                    size: 32,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _totalSessions.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total Sessions',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 32,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _totalMinutes.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total Minutes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(SessionHistory session, int index) {
    // Get meditation type info (icon, color, name)
    final typeInfo = _getMeditationTypeInfo(session.meditationType);
    final IconData icon = typeInfo['icon'];
    final Color color = typeInfo['color'];
    final String typeName = typeInfo['name'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  color.withOpacity(0.15),
                  color.withOpacity(0.05),
                ]
              : [
                  color.withOpacity(0.08),
                  color.withOpacity(0.03),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        typeName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatDuration(session.duration),
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(session.date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: color.withOpacity(0.7),
              ),
              onPressed: () => _deleteSession(session),
              tooltip: 'Delete session',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedSessions() {
    final groupedSessions = _groupSessionsByTime();
    final List<Widget> slivers = [];

    groupedSessions.forEach((groupName, sessions) {
      // Add section header
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Text(
                  groupName,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${sessions.length}',
                    style: TextStyle(
                      color: primaryAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Add sessions in this group
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final session = sessions[index];
              return _buildSessionCard(session, index);
            },
            childCount: sessions.length,
          ),
        ),
      );
    });

    // Add bottom padding
    slivers.add(
      const SliverToBoxAdapter(
        child: SizedBox(height: 20),
      ),
    );

    return slivers;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.self_improvement,
              size: 80,
              color: primaryAccent.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No meditation sessions yet',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start your meditation journey today!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Session History',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryAccent),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildStatsCard(),
                ),
                if (_sessions.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                else
                  ..._buildGroupedSessions(),
              ],
            ),
    );
  }
}
