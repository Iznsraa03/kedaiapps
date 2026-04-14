import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/logger.dart';
import '../../data/models/auth_model.dart';
import '../../logic/auth_viewmodel.dart';
import '../../ui/theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    return _ProfileContent(user: user, isFullScreen: true);
  }
}

/// Shared widget that renders profile content.
/// Used both inside the DraggableScrollableSheet and as a stand-alone screen.
class ProfileContent extends StatelessWidget {
  final UserModel? user;
  final bool isFullScreen;
  const ProfileContent({
    super.key,
    required this.user,
    this.isFullScreen = false,
  });

  @override
  Widget build(BuildContext context) => _ProfileContent(
    user: user,
    isFullScreen: isFullScreen,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Private implementation
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  final UserModel? user;
  final bool isFullScreen;

  const _ProfileContent({required this.user, required this.isFullScreen});

  void _onLogout(BuildContext context) {
    AppLogger.info('Logout requested from ProfileContent', 'ProfileScreen');
    context.read<AuthViewModel>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (c, a, b) => const LoginScreen(),
        transitionsBuilder: (c, animation, b, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayUser = user ??
        const UserModel(
          id: 0,
          fullName: 'Nama Lengkap',
          email: 'email@example.com',
          roleId: 0,
        );

    return Scaffold(
      backgroundColor: isFullScreen ? AppTheme.background : Colors.transparent,
      body: Column(
        children: [
          // ── Header biru ─────────────────────────────────────────────────
          _buildHeader(context, displayUser),
          // ── Detail cards ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  _infoCard(context, displayUser),
                  const SizedBox(height: 16),
                  _logoutButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Gradient header with avatar ───────────────────────────────────────────
  Widget _buildHeader(BuildContext context, UserModel user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: isFullScreen ? MediaQuery.of(context).padding.top + 16 : 20,
        bottom: 28,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Handle bar (only in bottom-sheet mode)
          if (!isFullScreen) ...[
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ] else ...[
            // Back button when full screen
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.20),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                alignment: Alignment.center,
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              user.roleId == 1 ? 'Admin' : 'Anggota',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────
  Widget _infoCard(BuildContext context, UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDark,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(Icons.email_outlined, 'Email', user.email),
          const Divider(height: 20),
          _infoRow(
            Icons.badge_rounded,
            'NRA',
            user.nra ?? 'Belum terdaftar',
            highlight: user.nra != null,
          ),
          const Divider(height: 20),
          _infoRow(
            Icons.verified_user_outlined,
            'Status',
            user.roleId == 1 ? 'Administrator' : 'Anggota Aktif',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool highlight = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.subtle),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: highlight ? AppTheme.primary : AppTheme.primaryDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _onLogout(context),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Keluar dari Akun'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.error,
          side: BorderSide(color: AppTheme.error.withValues(alpha: 0.50)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
