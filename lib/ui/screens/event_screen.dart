import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/logger.dart';
import '../../data/models/home_models.dart';
import '../../logic/event_viewmodel.dart';
import '../../ui/theme/app_theme.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with SingleTickerProviderStateMixin {
  // Staggered animation controller (per skill flutter-animating-apps)
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    AppLogger.info('EventScreen: initState', 'EventScreen');

    // Controller untuk staggered list animation
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Load data melalui ViewModel (UDF pattern dari skill flutter-architecting-apps)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventViewModel>().loadEvents();
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
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
              'Event',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Kegiatan & agenda organisasi 📅',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () {
              AppLogger.info('EventScreen: manual refresh', 'EventScreen');
              context.read<EventViewModel>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<EventViewModel>(
        builder: (context, vm, _) {
          // Saat selesai loading: jalankan staggered animation
          if (!vm.isLoading && vm.events.isNotEmpty) {
            _staggerController.forward(from: 0);
          }

          return Column(
            children: [
              // ── Filter Tab Bar ─────────────────────────────────────────
              _FilterTabBar(vm: vm),

              // ── Content Area ───────────────────────────────────────────
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

  Widget _buildBody(EventViewModel vm) {
    // Error state
    if (vm.errorMessage != null && !vm.isLoading) {
      return _ErrorView(
        message: vm.errorMessage!,
        onRetry: vm.refresh,
      );
    }

    // Skeleton loading — menggunakan Skeletonizer (sudah ada di project)
    if (vm.isLoading) {
      return Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: Colors.blue.shade50,
          highlightColor: Colors.blue.shade100,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: 3,
          itemBuilder: (_, i) => const _EventCardSkeleton(),
        ),
      );
    }

    // Empty state
    if (vm.events.isEmpty) {
      return _EmptyEventView(filter: vm.selectedFilter);
    }

    // List dengan staggered animation (per skill flutter-animating-apps)
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: vm.events.length,
      itemBuilder: (context, index) {
        // Staggered intervals per item
        final delay = index / vm.events.length;
        final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(
              delay * 0.6,
              math.min(delay * 0.6 + 0.4, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        );
        final slideAnim = Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(
              delay * 0.6,
              math.min(delay * 0.6 + 0.4, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        );

        return FadeTransition(
          opacity: fadeAnim,
          child: SlideTransition(
            position: slideAnim,
            child: _EventCard(event: vm.events[index]),
          ),
        );
      },
    );
  }
}

// ── Filter Tab Bar ─────────────────────────────────────────────────────────────

class _FilterTabBar extends StatelessWidget {
  final EventViewModel vm;
  const _FilterTabBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vm.filterOptions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final opt = vm.filterOptions[i];
            final isSelected = vm.selectedFilter == opt;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: GestureDetector(
                onTap: () => vm.setFilter(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
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

// ── Event Card ─────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(event.eventType);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Accent bar kiri + header ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: typeColor, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge baris
                  Row(
                    children: [
                      _TypeBadge(
                        label: event.typeLabel,
                        color: typeColor,
                      ),
                      const Spacer(),
                      // Status registrasi
                      _StatusBadge(isOpen: event.registrationOpen),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Judul
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Deskripsi (max 2 baris)
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ────────────────────────────────────────────────
            Divider(height: 1, color: Colors.grey.shade100),

            // ── Footer info ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Tanggal
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 13,
                    color: AppTheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _formatDateRange(event.startDate, event.endDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Lokasi
                  Icon(
                    Icons.location_on_rounded,
                    size: 13,
                    color: AppTheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'workshop':
        return const Color(0xFF7B1FA2); // ungu
      case 'seminar':
        return const Color(0xFF0277BD); // biru tua
      case 'competition':
        return const Color(0xFFE65100); // oranye
      case 'ceremony':
        return const Color(0xFF2E7D32); // hijau
      case 'gathering':
        return const Color(0xFFC62828); // merah
      default:
        return AppTheme.primary;
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final sameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
    if (sameDay) {
      return '${start.day} ${months[start.month]} ${start.year}';
    }
    return '${start.day} ${months[start.month]} – ${end.day} ${months[end.month]} ${end.year}';
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isOpen;
  const _StatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: isOpen ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isOpen ? 'Buka' : 'Tutup',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isOpen ? Colors.green.shade700 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

// ── Skeleton Card ──────────────────────────────────────────────────────────────

class _EventCardSkeleton extends StatelessWidget {
  const _EventCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              const Spacer(),
              Container(
                width: 50,
                height: 16,
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(width: double.infinity, height: 16, color: Colors.grey),
          const SizedBox(height: 6),
          Container(width: 200, height: 13, color: Colors.grey),
          const SizedBox(height: 12),
          Container(width: 150, height: 12, color: Colors.grey),
        ],
      ),
    );
  }
}

// ── Empty / Error Views ────────────────────────────────────────────────────────

class _EmptyEventView extends StatelessWidget {
  final String filter;
  const _EmptyEventView({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: AppTheme.primary.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            filter == 'Semua'
                ? 'Belum ada event'
                : 'Tidak ada event "$filter"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba pilih filter lain atau refresh halaman.',
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
