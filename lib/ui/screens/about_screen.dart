import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/logger.dart';
import '../../ui/theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final WebViewController _webController;
  bool _isLoading = true;
  bool _hasError = false;

  static const String _targetUrl = 'https://kedai.or.id';

  @override
  void initState() {
    super.initState();
    AppLogger.info('AboutScreen: loading WebView → $_targetUrl', 'AboutScreen');

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            AppLogger.info('WebView page started: $url', 'AboutScreen');
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (url) {
            AppLogger.success('WebView page finished: $url', 'AboutScreen');
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            AppLogger.error(
              'WebView error: ${error.description}',
              name: 'AboutScreen', // Fixed parameter: passed as named argument
            );
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            AppLogger.info('WebView navigate → ${request.url}', 'AboutScreen');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_targetUrl));
  }

  void _onRefresh() {
    AppLogger.info('WebView refresh triggered', 'AboutScreen');
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _webController.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _onRefresh,
        backgroundColor: AppTheme.primary,
        tooltip: 'Refresh',
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
      // ── Body: full-screen WebView ──────────────────────────────────────
      body: SafeArea(child: _hasError ? _buildErrorView() : _buildWebView()),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        // WebView memenuhi seluruh layar
        WebViewWidget(controller: _webController),

        // Progress bar loading di bagian atas
        if (_isLoading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
              color: AppTheme.primaryLight,
              minHeight: 3,
            ),
          ),
      ],
    );
  }

  /// Tampilan error jika halaman gagal dimuat
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 72,
              color: AppTheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            const Text(
              'Koneksi Gagal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan perangkat Anda terhubung ke internet,\nlalu coba refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
