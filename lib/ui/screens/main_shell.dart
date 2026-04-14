import 'package:flutter/material.dart';
import '../../ui/screens/about_screen.dart';
import '../../ui/screens/event_screen.dart';
import '../../ui/screens/home_screen.dart';
import '../../ui/screens/materi_screen.dart';
import '../../ui/theme/app_theme.dart';

/// Shell utama aplikasi dengan BottomNavigationBar.
/// Mengelola navigasi antar halaman: Home, Event, Materi, dan Tentang.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // Daftar halaman yang dikelola — diinisialisasi sekali (IndexedStack)
  static const List<Widget> _pages = [
    HomeScreen(),
    EventScreen(),
    MateriScreen(),
    AboutScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack mempertahankan state tiap halaman saat berganti tab
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.primary.withValues(alpha: 0.12),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          // ── Home ──────────────────────────────────────────────────
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: _selectedIndex == 0 ? AppTheme.primary : AppTheme.subtle,
            ),
            selectedIcon: const Icon(
              Icons.home_rounded,
              color: AppTheme.primary,
            ),
            label: 'Beranda',
          ),
          // ── Event ─────────────────────────────────────────────────
          NavigationDestination(
            icon: Icon(
              Icons.event_note_outlined,
              color: _selectedIndex == 1 ? AppTheme.primary : AppTheme.subtle,
            ),
            selectedIcon: const Icon(
              Icons.event_note_rounded,
              color: AppTheme.primary,
            ),
            label: 'Event',
          ),
          // ── Materi ────────────────────────────────────────────────
          NavigationDestination(
            icon: Icon(
              Icons.menu_book_outlined,
              color: _selectedIndex == 2 ? AppTheme.primary : AppTheme.subtle,
            ),
            selectedIcon: const Icon(
              Icons.menu_book_rounded,
              color: AppTheme.primary,
            ),
            label: 'Materi',
          ),
          // ── About — gunakan logo KDCW.png ─────────────────────────
          NavigationDestination(
            icon: _buildLogoIcon(isSelected: _selectedIndex == 3),
            selectedIcon: _buildLogoIcon(isSelected: true),
            label: 'Tentang',
          ),
        ],
      ),
    );
  }

  /// Widget ikon logo untuk tab "Tentang"
  Widget _buildLogoIcon({required bool isSelected}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 26,
      height: 26,
      decoration: isSelected
          ? BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withValues(alpha: 0.12),
            )
          : null,
      padding: const EdgeInsets.all(2),
      child: Image.asset(
        'assets/logo/KDCW.png',
        fit: BoxFit.contain,
        color: isSelected ? null : AppTheme.subtle,
        // Tint abu untuk unselected, tampil asli saat aktif
        colorBlendMode: isSelected ? null : BlendMode.srcIn,
      ),
    );
  }
}
