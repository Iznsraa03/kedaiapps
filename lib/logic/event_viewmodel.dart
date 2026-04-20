import 'package:flutter/foundation.dart';
import '../core/logger.dart';
import '../data/dummy_data.dart';
import '../data/models/home_models.dart';

/// ViewModel untuk halaman Event.
/// Mengelola state list event, filter tab, dan status loading.
class EventViewModel extends ChangeNotifier {
  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  bool isLoading = false;
  String? errorMessage;
  String _selectedFilter = 'Semua';

  final List<String> filterOptions = [
    'Semua',
    'Workshop',
    'Seminar',
    'Gathering',
    'Competition',
    'Ceremony',
  ];

  List<EventModel> get events => _filteredEvents;
  String get selectedFilter => _selectedFilter;

  /// Muat data event. Saat ini menggunakan dummy data.
  Future<void> loadEvents() async {
    AppLogger.info('EventViewModel: loadEvents() called', 'EventVM');
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Simulasi network delay — ganti dengan service call saat API siap
      await Future.delayed(const Duration(milliseconds: 800));
      _allEvents = List<EventModel>.from(dummyEvents);
      _applyFilter();
      AppLogger.success(
        'EventViewModel: loaded ${_allEvents.length} events',
        'EventVM',
      );
    } catch (e) {
      errorMessage = 'Gagal memuat event: $e';
      AppLogger.error(errorMessage!, name: 'EventVM');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Terapkan filter tab
  void setFilter(String filter) {
    AppLogger.info('EventViewModel: setFilter → $filter', 'EventVM');
    _selectedFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedFilter == 'Semua') {
      _filteredEvents = List<EventModel>.from(_allEvents);
    } else {
      final filterLower = _selectedFilter.toLowerCase();
      _filteredEvents = _allEvents
          .where((e) => e.eventType.toLowerCase() == filterLower)
          .toList();
    }
  }

  /// Refresh manual
  Future<void> refresh() => loadEvents();
}
