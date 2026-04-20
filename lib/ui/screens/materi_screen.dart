import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/logger.dart';
import '../../data/models/materi_model.dart';
import '../../logic/materi_viewmodel.dart';
import '../../ui/theme/app_theme.dart';

class MateriScreen extends StatefulWidget {
  const MateriScreen({super.key});

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger.info('MateriScreen: initState', 'MateriScreen');

    // Staggered animation controller
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MateriViewModel>().loadMateri();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 3,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Materi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Bahan belajar & referensi 📚',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () {
              AppLogger.info('MateriScreen: manual refresh', 'MateriScreen');
              context.read<MateriViewModel>().refresh();
            },
          ),
        ],
      ),

      body: Consumer<MateriViewModel>(
        builder: (context, vm, _) {
          if (!vm.isLoading && vm.materies.isNotEmpty) {
            _staggerController.forward(from: 0);
          }

          return Column(
            children: [
              // ── Search Bar ─────────────────────────────────────────
              _SearchBar(
                controller: _searchController,
                onChanged: vm.setSearchQuery,
              ),

              // ── Category Chips ─────────────────────────────────────
              if (!vm.isLoading) _CategoryChips(vm: vm),

              // ── Content ────────────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: vm.refresh,
                  child: _buildBody(vm),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(MateriViewModel vm) {
    if (vm.errorMessage != null && !vm.isLoading) {
      return _ErrorView(message: vm.errorMessage!, onRetry: vm.refresh);
    }

    if (vm.isLoading) {
      return Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: Colors.blue.shade50,
          highlightColor: Colors.blue.shade100,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: 5,
          itemBuilder: (_, i) => const _MateriCardSkeleton(),
        ),
      );
    }

    if (vm.materies.isEmpty) {
      return _EmptyMateriView(query: vm.searchQuery);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: vm.materies.length,
      itemBuilder: (context, index) {
        final delay = index / math.max(vm.materies.length, 1);
        final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(
              delay * 0.5,
              math.min(delay * 0.5 + 0.5, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        );
        final slideAnim = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(
              delay * 0.5,
              math.min(delay * 0.5 + 0.5, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        );

        return FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: slideAnim,
            child: _MateriCard(materi: vm.materies[index]),
          ),
        );
      },
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cari materi, topik, penulis...',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(Icons.close_rounded, size: 18),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
          filled: true,
          fillColor: AppTheme.background,
        ),
      ),
    );
  }
}

// ── Category Chips ─────────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final MateriViewModel vm;
  const _CategoryChips({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vm.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final cat = vm.categories[i];
            final isSelected = vm.selectedCategory == cat;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              child: GestureDetector(
                onTap: () => vm.setCategory(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Materi Card ────────────────────────────────────────────────────────────────

class _MateriCard extends StatelessWidget {
  final MateriModel materi;
  const _MateriCard({required this.materi});

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(materi.fileType);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            AppLogger.info(
              'MateriCard tapped: ${materi.title}',
              'MateriScreen',
            );
            // TODO: navigasi ke detail materi
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ── Icon file type ───────────────────────────────────
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: typeColor.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      materi.fileTypeIcon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // ── Info ─────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris atas: judul + badge baru
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              materi.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ),
                          if (materi.isNew) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Text(
                                'Baru',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Deskripsi singkat
                      Text(
                        materi.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Baris bawah: kategori, type, views
                      Row(
                        children: [
                          _SmallChip(
                            label: materi.category,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 6),
                          _SmallChip(
                            label: materi.fileTypeLabel,
                            color: typeColor,
                          ),
                          const Spacer(),
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 12,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${materi.viewCount}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Arrow ────────────────────────────────────────────
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'pdf':
        return const Color(0xFFD32F2F);
      case 'video':
        return const Color(0xFFE64A19);
      case 'link':
        return const Color(0xFF0277BD);
      case 'doc':
        return const Color(0xFF1565C0);
      default:
        return AppTheme.primary;
    }
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SmallChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Skeleton Card ──────────────────────────────────────────────────────────────

class _MateriCardSkeleton extends StatelessWidget {
  const _MateriCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.grey,
                ),
                const SizedBox(height: 6),
                Container(width: 200, height: 12, color: Colors.grey),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 45,
                      height: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty / Error Views ────────────────────────────────────────────────────────

class _EmptyMateriView extends StatelessWidget {
  final String query;
  const _EmptyMateriView({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppTheme.primary.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'Belum ada materi' : 'Materi tidak ditemukan',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            query.isEmpty
                ? 'Materi akan segera tersedia.'
                : 'Coba kata kunci lain atau pilih kategori berbeda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: AppTheme.primary.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
