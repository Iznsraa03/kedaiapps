import 'package:flutter/foundation.dart';
import '../core/logger.dart';
import '../data/dummy_data.dart';
import '../data/models/materi_model.dart';

/// ViewModel untuk halaman Materi.
/// Mengelola state list materi, filter kategori, dan pencarian.
class MateriViewModel extends ChangeNotifier {
  List<MateriModel> _allMateri = [];
  List<MateriModel> _filteredMateri = [];
  bool isLoading = false;
  String? errorMessage;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  // Kategori unik dari data
  List<String> get categories {
    final cats = _allMateri.map((m) => m.category).toSet().toList()..sort();
    return ['Semua', ...cats];
  }

  List<MateriModel> get materies => _filteredMateri;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  /// Muat data materi. Saat ini menggunakan dummy data.
  Future<void> loadMateri() async {
    AppLogger.info('MateriViewModel: loadMateri() called', 'MateriVM');
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Simulasi network delay — ganti dengan service call saat API siap
      await Future.delayed(const Duration(milliseconds: 700));
      _allMateri = List<MateriModel>.from(dummyMateri);
      _applyFilter();
      AppLogger.success(
        'MateriViewModel: loaded ${_allMateri.length} materi',
        'MateriVM',
      );
    } catch (e) {
      errorMessage = 'Gagal memuat materi: $e';
      AppLogger.error(errorMessage!, name: 'MateriVM');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Filter berdasarkan kategori
  void setCategory(String category) {
    AppLogger.info('MateriViewModel: setCategory → $category', 'MateriVM');
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  /// Filter berdasarkan search query
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    var list = _allMateri;

    // Filter kategori
    if (_selectedCategory != 'Semua') {
      list = list.where((m) => m.category == _selectedCategory).toList();
    }

    // Filter search
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (m) =>
                m.title.toLowerCase().contains(_searchQuery) ||
                m.description.toLowerCase().contains(_searchQuery) ||
                m.author.toLowerCase().contains(_searchQuery),
          )
          .toList();
    }

    _filteredMateri = list;
  }

  /// Refresh manual
  Future<void> refresh() => loadMateri();
}
