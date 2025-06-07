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

import 'package:flutter/foundation.dart';
import 'package:windchime/data/repositories/guided_meditation_repository.dart';
import 'package:windchime/models/meditation/guided_meditation.dart';
import 'package:windchime/models/meditation/guided_meditation_category.dart';
import 'package:windchime/services/guided_meditation_service.dart';

class GuidedMeditationProvider extends ChangeNotifier {
  final GuidedMeditationRepository _repository = GuidedMeditationRepository();
  final GuidedMeditationService _service = GuidedMeditationService();

  // Data state
  List<GuidedMeditationCategory> _categories = [];
  List<GuidedMeditation> _allMeditations = [];
  List<GuidedMeditation> _filteredMeditations = [];
  final Map<String, List<GuidedMeditation>> _meditationsByCategory = {};

  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategoryId;

  // Getters
  List<GuidedMeditationCategory> get categories => _categories;
  List<GuidedMeditation> get allMeditations => _allMeditations;
  List<GuidedMeditation> get filteredMeditations => _filteredMeditations;
  Map<String, List<GuidedMeditation>> get meditationsByCategory =>
      _meditationsByCategory;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  GuidedMeditationService get service => _service;

  // Popular meditations
  List<GuidedMeditation> get popularMeditations {
    return _allMeditations.where((meditation) => meditation.isPopular).toList();
  }

  // Recently added (last 5)
  List<GuidedMeditation> get recentMeditations {
    return _allMeditations.take(5).toList();
  }

  // Initialize the provider
  Future<void> initialize() async {
    await loadData();
    await _service.initialize();
  }

  // Load all data
  Future<void> loadData() async {
    _setLoading(true);
    _setError(null);

    try {
      _categories = _repository.getAllCategories();
      _allMeditations = _repository.getAllMeditations();
      _filteredMeditations = _allMeditations;

      // Group meditations by category
      _meditationsByCategory.clear();
      for (final category in _categories) {
        _meditationsByCategory[category.id] =
            _repository.getMeditationsByCategory(category.id);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load meditation data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search meditations
  void searchMeditations(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredMeditations = _selectedCategoryId != null
          ? _meditationsByCategory[_selectedCategoryId!] ?? []
          : _allMeditations;
    } else {
      List<GuidedMeditation> searchResults =
          _repository.searchMeditations(query);

      // Filter by category if one is selected
      if (_selectedCategoryId != null) {
        searchResults = searchResults
            .where((meditation) => meditation.categoryId == _selectedCategoryId)
            .toList();
      }

      _filteredMeditations = searchResults;
    }

    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;

    if (categoryId == null) {
      _filteredMeditations = _searchQuery.isEmpty
          ? _allMeditations
          : _repository.searchMeditations(_searchQuery);
    } else {
      _filteredMeditations = _searchQuery.isEmpty
          ? _meditationsByCategory[categoryId] ?? []
          : _repository
              .searchMeditations(_searchQuery)
              .where((meditation) => meditation.categoryId == categoryId)
              .toList();
    }

    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _filteredMeditations = _allMeditations;
    notifyListeners();
  }

  // Get category by ID
  GuidedMeditationCategory? getCategoryById(String categoryId) {
    return _repository.getCategoryById(categoryId);
  }

  // Get meditation by ID
  GuidedMeditation? getMeditationById(String meditationId) {
    return _repository.getMeditationById(meditationId);
  }

  // Get meditations for a specific category
  List<GuidedMeditation> getMeditationsForCategory(String categoryId) {
    return _meditationsByCategory[categoryId] ?? [];
  }

  // Get meditations by duration range
  List<GuidedMeditation> getMeditationsByDuration(
      int minMinutes, int maxMinutes) {
    final minSeconds = minMinutes * 60;
    final maxSeconds = maxMinutes * 60;
    return _repository.getMeditationsByDuration(minSeconds, maxSeconds);
  }

  // Get meditations by instructor
  List<GuidedMeditation> getMeditationsByInstructor(String instructor) {
    return _repository.getMeditationsByInstructor(instructor);
  }

  // Get all unique instructors
  List<String> getAllInstructors() {
    final instructors = <String>{};
    for (final meditation in _allMeditations) {
      instructors.add(meditation.instructor);
    }
    return instructors.toList()..sort();
  }

  // Get meditation statistics
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{};

    stats['totalMeditations'] = _allMeditations.length;
    stats['totalCategories'] = _categories.length;
    stats['totalInstructors'] = getAllInstructors().length;

    // Duration statistics
    final durations = _allMeditations.map((m) => m.durationSeconds).toList();
    if (durations.isNotEmpty) {
      durations.sort();
      stats['shortestDuration'] = durations.first;
      stats['longestDuration'] = durations.last;
      stats['averageDuration'] =
          durations.reduce((a, b) => a + b) ~/ durations.length;
    }

    // Category distribution
    final categoryDistribution = <String, int>{};
    for (final category in _categories) {
      categoryDistribution[category.name] =
          _meditationsByCategory[category.id]?.length ?? 0;
    }
    stats['categoryDistribution'] = categoryDistribution;

    return stats;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadData();
  }

  // Check if a category has meditations
  bool categoryHasMeditations(String categoryId) {
    return (_meditationsByCategory[categoryId]?.isNotEmpty) ?? false;
  }

  // Get meditation count for category
  int getMeditationCountForCategory(String categoryId) {
    return _meditationsByCategory[categoryId]?.length ?? 0;
  }

  // Sort meditations
  void sortMeditations(String sortBy) {
    switch (sortBy) {
      case 'title':
        _filteredMeditations.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'duration':
        _filteredMeditations
            .sort((a, b) => a.durationSeconds.compareTo(b.durationSeconds));
        break;
      case 'instructor':
        _filteredMeditations
            .sort((a, b) => a.instructor.compareTo(b.instructor));
        break;
      case 'popular':
        _filteredMeditations.sort((a, b) {
          if (a.isPopular && !b.isPopular) return -1;
          if (!a.isPopular && b.isPopular) return 1;
          return 0;
        });
        break;
      default:
        // Keep original order
        break;
    }
    notifyListeners();
  }
}
