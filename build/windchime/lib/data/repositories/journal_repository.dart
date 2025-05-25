import 'package:prog2435_final_project_app/data/db_helper.dart';
import 'package:prog2435_final_project_app/models/journal/journal_entry.dart';

class JournalRepository {
  final DbHelper _dbHelper;

  JournalRepository(this._dbHelper);

  Future<List<JournalEntry>> getAllEntries() async {
    final List<Map<String, dynamic>> maps =
        await _dbHelper.readDb('journal_entries');
    return List.generate(maps.length, (i) => JournalEntry.fromMap(maps[i]));
  }

  Future<int> insertEntry(JournalEntry entry) async {
    return await _dbHelper.insertDb(entry.toMap(), 'journal_entries');
  }

  Future<int> updateEntry(JournalEntry entry) async {
    return await _dbHelper.updateDb(entry.toMap(), 'journal_entries');
  }

  Future<int> deleteEntry(int id) async {
    return await _dbHelper.deleteDb(id, 'journal_entries');
  }
}
