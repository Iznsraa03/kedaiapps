import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/logger.dart';
import '../../logic/auth_viewmodel.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/auth_widgets.dart';
import 'main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _slideIn = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    AppLogger.info('Login button pressed', 'LoginScreen');
    if (!_formKey.currentState!.validate()) {
      AppLogger.warning('Form validation failed', 'LoginScreen');
      return;
    }

    final vm = context.read<AuthViewModel>();
    final success = await vm.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      AppLogger.success('Login succeeded, navigating to HomeScreen', 'LoginScreen');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a, b) => const MainShell(),
          transitionsBuilder: (c, animation, b, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      final error = vm.errorMessage ?? 'Terjadi kesalahan';
      AppLogger.warning('Login failed, showing Snackbar: $error', 'LoginScreen');
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
          // Decorative wave header
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.50,
            child: AnimatedBlueWave(),
          ),

          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo & Title (in blue area)
                  _buildHeader(),

                  const SizedBox(height: 32),

                  // Form card
                  SlideTransition(
                    position: _slideIn,
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: _buildFormCard(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Register link
                  FadeTransition(opacity: _fadeIn, child: _buildRegisterLink()),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryDark.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/logo/KDCW.png', fit: BoxFit.contain),
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'KedaiApp',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Masuk ke akun Anda',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 0.2,
          ),
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
              'Selamat Datang',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Silakan isi data login Anda di bawah ini',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 28),

            // Email field
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

            // Password field
            AppTextField(
              label: 'Password',
              prefixIcon: Icons.lock_rounded,
              controller: _passwordController,
              isPassword: true,
              textInputAction: TextInputAction.done,
              onEditingComplete: _onLogin,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                if (v.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
            ),

            const SizedBox(height: 8),

            // // Forgot password
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: TextButton(
            //     onPressed: () {},
            //     child: const Text(
            //       'Lupa Password?',
            //       style: TextStyle(
            //         color: AppTheme.primaryLight,
            //         fontSize: 13,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 8),

            // Login button
            Consumer<AuthViewModel>(
              builder: (context, vm, _) => AppPrimaryButton(
                text: 'Masuk',
                isLoading: vm.isLoading,
                onPressed: _onLogin,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            context.read<AuthViewModel>().reset();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, animation, __) => const RegisterScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                    child: child,
                  );
                },
              ),
            );
          },
          child: const Text(
            'Daftar Sekarang',
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
