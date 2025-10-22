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

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangelogService {
  static const String _lastShownVersionKey = 'last_shown_changelog_version';

  /// Checks if the changelog should be shown (i.e., app was updated)
  static Future<bool> shouldShowChangelog() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final prefs = await SharedPreferences.getInstance();
      final lastShownVersion = prefs.getString(_lastShownVersionKey);

      // If no version stored or version is different, show changelog
      if (lastShownVersion == null || lastShownVersion != currentVersion) {
        return true;
      }

      return false;
    } catch (e) {
      // If there's an error, don't show changelog to avoid crashes
      return false;
    }
  }

  /// Marks the current version as shown, so changelog won't appear again
  static Future<void> markChangelogAsShown() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastShownVersionKey, currentVersion);
    } catch (e) {
      // Silently fail if there's an error
    }
  }
}
