import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/logger.dart';
import '../../data/home_placeholder.dart';
import '../../data/models/auth_model.dart';
import '../../logic/auth_viewmodel.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/home_cards.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Skeletonizer state — true selama simulasi loading awal
  bool _isLoading = true;

  // Entrance animation
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    AppLogger.info('HomeScreen initState', 'HomeScreen');

    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );
    _animController.forward();

    // Simulasikan loading profile selama 1.5 detik
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        AppLogger.success(
          'Profile data ready, disabling skeleton',
          'HomeScreen',
        );
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _showProfileSheet() {
    AppLogger.info('Profile sheet opened', 'HomeScreen');
    final user = context.read<AuthViewModel>().currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      builder: (_) => _ProfileBottomSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 3,
        automaticallyImplyLeading: false,
        // Title: "Beranda" + subtitle
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beranda',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Selamat datang kembali 👋',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.80),
                fontSize: 12,
              ),
            ),
          ],
        ),
        // Profile action button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _showProfileSheet,
              child: Consumer<AuthViewModel>(
                builder: (_, vm, _x) {
                  final user = vm.currentUser;
                  return Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.white24, Colors.white10],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.50),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user?.initials ?? '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Profile Card (Fixed) ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: SlideTransition(
              position: _slideIn,
              child: FadeTransition(
                opacity: _fadeIn,
                child: Consumer<AuthViewModel>(
                  builder: (context, vm, _) =>
                      _buildProfileCard(vm.currentUser),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          // ── Scrollable Content ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Event Terbaru ────────────────────────────────────────
                  _buildSectionHeader(
                    'Event Terbaru',
                    Icons.event_note_rounded,
                    onSeeAll: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildEventList(),

                  const SizedBox(height: 28),

                  // ── Berita IT ────────────────────────────────────────────
                  _buildSectionHeader(
                    'Berita IT Terkini',
                    Icons.newspaper_rounded,
                    onSeeAll: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildNewsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu profil horizontal: avatar kiri, info kanan
  Widget _buildProfileCard(UserModel? user) {
    final displayUser =
        user ??
        const UserModel(
          id: 0,
          fullName: 'Nama Lengkap User',
          email: 'emailcontoh@example.com',
          roleId: 0,
          nra: 'NRA-Placeholder',
        );

    return Skeletonizer(
      enabled: _isLoading,
      effect: ShimmerEffect(
        baseColor: Colors.blue.shade50,
        highlightColor: Colors.blue.shade100,
        duration: const Duration(milliseconds: 1000),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.09),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar kiri ─────────────────────────────────────────────
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    displayUser.initials,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Badge online
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Info kanan ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama
                  Text(
                    displayUser.fullName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Email
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 12,
                        color: AppTheme.primary.withValues(alpha: 0.65),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          displayUser.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // NRA chip (jika ada)
                  if (!_isLoading && displayUser.nra != null) ...[
                    const SizedBox(height: 8),
                    _buildNraChip(displayUser.nra!),
                  ] else if (_isLoading) ...[
                    const SizedBox(height: 8),
                    _buildNraChip('NRA-Placeholder'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNraChip(String nra) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.badge_rounded, size: 12, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            'NRA: $nra',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header: judul + tombol "Lihat Semua" ─────────────────────────
  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    required VoidCallback onSeeAll,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppTheme.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Event list: vertical scroll ────────────────────────────────────────
  Widget _buildEventList() {
    return Skeletonizer(
      enabled: _isLoading,
      effect: ShimmerEffect(
        baseColor: Colors.blue.shade50,
        highlightColor: Colors.blue.shade100,
        duration: const Duration(milliseconds: 1000),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: placeholderEvents.length,
        separatorBuilder: (_, _s) => const SizedBox(height: 16),
        itemBuilder: (context, i) =>
            EventCard(event: placeholderEvents[i], onTap: () {}),
      ),
    );
  }

  // ── News list: horizontal scroll ──────────────────────────────────────────
  Widget _buildNewsList() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 4),
        itemCount: placeholderNews.length,
        separatorBuilder: (_, _s) => const SizedBox(width: 12),
        itemBuilder: (context, i) =>
            NewsCard(news: placeholderNews[i], onTap: () {}),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Draggable bottom sheet yang bisa digeser ke atas → buka ProfileScreen
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileBottomSheet extends StatefulWidget {
  final UserModel? user;
  const _ProfileBottomSheet({required this.user});

  @override
  State<_ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<_ProfileBottomSheet> {
  final DraggableScrollableController _dragController =
      DraggableScrollableController();

  // When the sheet reaches ~95 % of screen height, navigate to full screen.
  static const double _fullThreshold = 0.94;

  @override
  void initState() {
    super.initState();
    _dragController.addListener(_onDragChanged);
  }

  void _onDragChanged() {
    if (_dragController.isAttached &&
        _dragController.size >= _fullThreshold &&
        mounted) {
      // Remove listener to prevent repeated triggers
      _dragController.removeListener(_onDragChanged);
      Navigator.of(context).pop(); // close the sheet first
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (c, a, b) => const ProfileScreen(),
          transitionsBuilder: (c, animation, b, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    }
  }

  @override
  void dispose() {
    _dragController.removeListener(_onDragChanged);
    _dragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _dragController,
      initialChildSize: 0.60,
      minChildSize: 0.40,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [0.60, 1.0],
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ProfileContent(user: widget.user, isFullScreen: false),
            ),
          ),
        );
      },
    );
  }
}
