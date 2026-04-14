import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/logger.dart';
import '../../logic/auth_viewmodel.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Standard fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // NRA sub-fields
  final _nomorAnggotaController = TextEditingController(); // e.g. 973
  final _angkatanController = TextEditingController();     // e.g. XXII (romawi)
  final _tahunMasukController = TextEditingController();   // e.g. 23
  final _nraResultController = TextEditingController();    // read-only assembled result
  static const String _kodeOrganisasi = 'KD';             // fixed, tidak berubah

  // BPH toggle state
  bool _isBPH = false;

  // Entrance animation
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();

    // Entrance animation setup
    _animController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _slideIn = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );

    _animController.forward();

    // Auto-assemble NRA result whenever any sub-field changes
    _nomorAnggotaController.addListener(_updateNraResult);
    _angkatanController.addListener(_updateNraResult);
    _tahunMasukController.addListener(_updateNraResult);
  }

  /// Assembles the NRA string from sub-fields → format: 973.KD.XXII.23
  void _updateNraResult() {
    final nomor = _nomorAnggotaController.text.trim();
    final angkatan = _angkatanController.text.trim().toUpperCase();
    final tahun = _tahunMasukController.text.trim();

    if (nomor.isNotEmpty || angkatan.isNotEmpty || tahun.isNotEmpty) {
      _nraResultController.text = '$nomor.$_kodeOrganisasi.$angkatan.$tahun';
      AppLogger.info('NRA auto-assembled: ${_nraResultController.text}', 'RegisterScreen');
    } else {
      _nraResultController.text = '';
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomorAnggotaController.dispose();
    _angkatanController.dispose();
    _tahunMasukController.dispose();
    _nraResultController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    AppLogger.info('Register button pressed', 'RegisterScreen');
    if (!_formKey.currentState!.validate()) {
      AppLogger.warning('Form validation failed', 'RegisterScreen');
      return;
    }

    // Hanya kirim NRA jika pengguna adalah BPH
    String? nraValue;
    if (_isBPH) {
      final assembled = _nraResultController.text.trim();
      nraValue = assembled.isNotEmpty ? assembled : null;
      AppLogger.info('BPH toggled ON. Evaluated NRA value: $nraValue', 'RegisterScreen');
    } else {
      AppLogger.info('BPH toggled OFF. NRA value is null', 'RegisterScreen');
    }

    final vm = context.read<AuthViewModel>();
    final success = await vm.register(
      email: _emailController.text.trim(),
      fullName: _nameController.text.trim(),
      password: _passwordController.text,
      nra: nraValue,
    );

    if (!mounted) return;

    if (success) {
      AppLogger.success('Register succeeded, showing Snackbar', 'RegisterScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      final error = vm.errorMessage ?? 'Terjadi kesalahan';
      AppLogger.warning('Register failed, showing Snackbar: $error', 'RegisterScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Decorative header wave with entrance animation
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.50,
            child: AnimatedBlueWave(),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Back button + title
                  _buildHeader(context),

                  const SizedBox(height: 24),

                  // Form card with entrance animation
                  SlideTransition(
                    position: _slideIn,
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: _buildFormCard(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login link
                  FadeTransition(opacity: _fadeIn, child: _buildLoginLink()),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Akun Baru',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Bergabung dengan KedaiApp',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Akun',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Isi data diri Anda untuk mendaftar',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),

            // ── BPH Toggle ─────────────────────────────────────────────────
            _buildBphToggle(),

            const SizedBox(height: 24),

            // ── Standard Fields ────────────────────────────────────────────
            // Full Name
            AppTextField(
              label: 'Nama Lengkap',
              hint: 'John Doe',
              prefixIcon: Icons.person_rounded,
              controller: _nameController,
              keyboardType: TextInputType.name,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nama tidak boleh kosong';
                if (v.length < 3) return 'Nama minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            AppTextField(
              label: 'Email',
              hint: 'contoh@email.com',
              prefixIcon: Icons.email_rounded,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                if (!v.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            AppTextField(
              label: 'Password',
              prefixIcon: Icons.lock_rounded,
              controller: _passwordController,
              isPassword: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                if (v.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password
            AppTextField(
              label: 'Konfirmasi Password',
              prefixIcon: Icons.lock_outline_rounded,
              controller: _confirmPasswordController,
              isPassword: true,
              textInputAction: TextInputAction.done,
              onEditingComplete: _isBPH ? null : _onRegister,
              validator: (v) {
                if (v == null || v.isEmpty)
                  return 'Konfirmasi password tidak boleh kosong';
                if (v != _passwordController.text) return 'Password tidak cocok';
                return null;
              },
            ),

            // ── NRA Section (animasi muncul/hilang) ───────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              child: _isBPH ? _buildNraSection() : const SizedBox.shrink(),
            ),

            const SizedBox(height: 28),

            // Register Button
            Consumer<AuthViewModel>(
              builder: (context, vm, _) => AppPrimaryButton(
                text: 'Daftar Sekarang',
                isLoading: vm.isLoading,
                onPressed: _onRegister,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle card: apakah user ini anggota BPH?
  Widget _buildBphToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isBPH
            ? AppTheme.primary.withValues(alpha: 0.08)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isBPH ? AppTheme.primary.withValues(alpha: 0.3) : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isBPH ? AppTheme.primary : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.admin_panel_settings_rounded,
              size: 18,
              color: _isBPH ? Colors.white : Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 12),
          // Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anggota BPH',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _isBPH ? AppTheme.primary : Colors.grey.shade700,
                  ),
                ),
                Text(
                  'Aktifkan jika Anda adalah Badan Pengurus Harian',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // Switch
          Switch(
            value: _isBPH,
            onChanged: (val) {
              AppLogger.info('BPH switch toggled: $val', 'RegisterScreen');
              setState(() {
                _isBPH = val;
                if (!val) {
                  // Reset NRA fields saat toggle dimatikan
                  _nomorAnggotaController.clear();
                  _angkatanController.clear();
                  _tahunMasukController.clear();
                  _nraResultController.clear();
                }
              });
            },
            activeThumbColor: AppTheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  /// Form NRA yang muncul hanya saat _isBPH = true
  Widget _buildNraSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section divider + label
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade200)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(Icons.badge_rounded, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Nomor Registrasi Anggota (NRA)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade200)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Contoh hasil NRA: 973.KD.XXII.23',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),

          // Row 1: Nomor Anggota + Kode Organisasi (fixed chip)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nomor Anggota
              Expanded(
                flex: 3,
                child: AppTextField(
                  label: 'No. Anggota',
                  hint: '973',
                  prefixIcon: Icons.tag_rounded,
                  controller: _nomorAnggotaController,
                  keyboardType: TextInputType.number,
                  validator: _isBPH
                      ? (v) {
                          if (v == null || v.isEmpty)
                            return 'Wajib diisi';
                          return null;
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Kode Organisasi (fixed, non-editable chip)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kode Org.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(12),
                        color: AppTheme.primary.withValues(alpha: 0.05),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _kodeOrganisasi,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: Angkatan (romawi) + Tahun Masuk
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Angkatan (roman numeral)
              Expanded(
                child: AppTextField(
                  label: 'Angkatan',
                  hint: 'XXII',
                  prefixIcon: Icons.school_rounded,
                  controller: _angkatanController,
                  keyboardType: TextInputType.text,
                  validator: _isBPH
                      ? (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          return null;
                        }
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Tahun Masuk
              Expanded(
                child: AppTextField(
                  label: 'Tahun Masuk',
                  hint: '23',
                  prefixIcon: Icons.calendar_today_rounded,
                  controller: _tahunMasukController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _onRegister,
                  validator: _isBPH
                      ? (v) {
                          if (v == null || v.isEmpty) return 'Wajib diisi';
                          return null;
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // NRA Result (read-only preview)
          _buildNraResultField(),
        ],
      ),
    );
  }

  /// Read-only field that shows the assembled NRA
  Widget _buildNraResultField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hasil NRA',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: Listenable.merge([
            _nomorAnggotaController,
            _angkatanController,
            _tahunMasukController,
          ]),
          builder: (context, _) {
            final isComplete =
                _nomorAnggotaController.text.isNotEmpty &&
                _angkatanController.text.isNotEmpty &&
                _tahunMasukController.text.isNotEmpty;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isComplete
                    ? AppTheme.primary.withValues(alpha: 0.06)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isComplete
                      ? AppTheme.primary.withValues(alpha: 0.4)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isComplete
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: isComplete ? AppTheme.primary : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isComplete
                          ? _nraResultController.text
                          : 'Isi semua field NRA di atas...',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isComplete ? FontWeight.bold : FontWeight.normal,
                        color: isComplete
                            ? AppTheme.primary
                            : Colors.grey.shade400,
                        letterSpacing: isComplete ? 1.2 : 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Masuk di sini',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
