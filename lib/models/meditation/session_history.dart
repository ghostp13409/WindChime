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
class SessionHistory {
  int? id;
  final DateTime date;
  final int duration;
  final String? meditationType;

  SessionHistory({
    this.id,
    required this.date,
    required this.duration,
    this.meditationType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'duration': duration,
      'meditation_type': meditationType,
    };
  }

  factory SessionHistory.fromMap(Map<String, dynamic> map) {
    return SessionHistory(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      duration: map['duration'] as int,
      meditationType: map['meditation_type'] as String?,
    );
  }

  @override
  String toString() {
    return 'SessionHistory{id: $id, date: $date, duration: $duration, meditationType: $meditationType}';
  }
}
