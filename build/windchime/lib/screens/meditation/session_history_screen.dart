import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sessions = await _meditationRepository.getAllSessions();
    final totalSessions = await _meditationRepository.getTotalSessionsCount();
    final totalMinutes =
        await _meditationRepository.getTotalMeditationMinutes();

    setState(() {
      _sessions = sessions;
      _totalSessions = totalSessions;
      _totalMinutes =
          totalMinutes ~/ 60; // Convert seconds to minutes for total
    });
  }

  Future<void> _deleteSession(SessionHistory session) async {
    await _meditationRepository.deleteSession(session.id!);
    _loadData(); // Refresh the list
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes min $remainingSeconds sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _totalSessions.toString(),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Text('Total Sessions'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _totalMinutes.toString(),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Text('Total Minutes'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      '${session.duration ~/ 60}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    DateFormat('MMM d, y - h:mm a').format(session.date),
                  ),
                  subtitle: Text(_formatDuration(session.duration)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteSession(session),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
