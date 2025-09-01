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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum ThemeModeOption {
  light,
  dark,
  system,
}

class ThemeProvider with ChangeNotifier {
  ThemeModeOption _themeMode = ThemeModeOption.dark;
  bool _systemIsDark = false;

  ThemeProvider() {
    // Initialize system theme detection
    _updateSystemTheme();
  }

  ThemeModeOption get themeMode => _themeMode;

  bool get isDarkTheme {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return false;
      case ThemeModeOption.dark:
        return true;
      case ThemeModeOption.system:
        return _systemIsDark;
    }
  }

  void setThemeMode(ThemeModeOption mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    // Cycle through light -> dark -> system -> light...
    switch (_themeMode) {
      case ThemeModeOption.light:
        _themeMode = ThemeModeOption.dark;
        break;
      case ThemeModeOption.dark:
        _themeMode = ThemeModeOption.system;
        break;
      case ThemeModeOption.system:
        _themeMode = ThemeModeOption.light;
        break;
    }
    notifyListeners();
  }

  void _updateSystemTheme() {
    // This will be called when the app starts to detect system theme
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    _systemIsDark = brightness == Brightness.dark;
  }

  void updateSystemTheme(bool isDark) {
    _systemIsDark = isDark;
    if (_themeMode == ThemeModeOption.system) {
      notifyListeners();
    }
  }

  String getThemeModeDisplayName() {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return 'Light';
      case ThemeModeOption.dark:
        return 'Dark';
      case ThemeModeOption.system:
        return 'System (${_systemIsDark ? 'Dark' : 'Light'})';
    }
  }
}
