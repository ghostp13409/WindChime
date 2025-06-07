/*
 * Copyright (C) 2025 Parth Gajjar
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:windchime/data/db_helper.dart';
import 'package:windchime/models/meditation/session_history.dart';

class MeditationRepository {
  final dbHelper = DbHelper.dbHero;
  final String tableName = 'meditation_sessions';

  Future<SessionHistory> addSession(SessionHistory session) async {
    final id = await dbHelper.insertDb(session.toMap(), tableName);
    return SessionHistory(
      id: id,
      date: session.date,
      duration: session.duration,
      meditationType: session.meditationType,
    );
  }

  Future<List<SessionHistory>> getAllSessions() async {
    final List<Map<String, dynamic>> maps = await dbHelper.readDb(tableName);
    return List.generate(maps.length, (i) {
      return SessionHistory.fromMap(maps[i]);
    });
  }

  Future<bool> deleteSession(int id) async {
    final result = await dbHelper.deleteDb(id, tableName);
    return result > 0;
  }

  Future<List<SessionHistory>> getSessionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    final Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );
    return List.generate(maps.length, (i) {
      return SessionHistory.fromMap(maps[i]);
    });
  }

  Future<int> getTotalSessionsCount() async {
    final Database db = await dbHelper.database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getTotalMeditationMinutes() async {
    final Database db = await dbHelper.database;
    final result =
        await db.rawQuery('SELECT SUM(duration) as total FROM $tableName');
    return result.first['total'] as int? ?? 0;
  }

  // Get sessions filtered by type (breathwork vs guided)
  Future<List<SessionHistory>> getBreathworkSessions() async {
    final Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'meditation_type NOT LIKE ? AND meditation_type NOT LIKE ?',
      whereArgs: ['guided_%', '%_partial'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return SessionHistory.fromMap(maps[i]);
    });
  }

  Future<List<SessionHistory>> getGuidedMeditationSessions() async {
    final Database db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'meditation_type LIKE ?',
      whereArgs: ['guided_%'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return SessionHistory.fromMap(maps[i]);
    });
  }

  // Get counts and totals for specific types
  Future<int> getBreathworkSessionsCount() async {
    final Database db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE meditation_type NOT LIKE ? AND meditation_type NOT LIKE ?',
      ['guided_%', '%_partial'],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getGuidedMeditationSessionsCount() async {
    final Database db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE meditation_type LIKE ?',
      ['guided_%'],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getBreathworkTotalMinutes() async {
    final Database db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(duration) as total FROM $tableName WHERE meditation_type NOT LIKE ? AND meditation_type NOT LIKE ?',
      ['guided_%', '%_partial'],
    );
    return result.first['total'] as int? ?? 0;
  }

  Future<int> getGuidedMeditationTotalMinutes() async {
    final Database db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(duration) as total FROM $tableName WHERE meditation_type LIKE ?',
      ['guided_%'],
    );
    return result.first['total'] as int? ?? 0;
  }
}
