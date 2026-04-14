import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'logic/auth_viewmodel.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi data locale Bahasa Indonesia untuk intl / DateFormat
  await initializeDateFormatting('id_ID', null);
  runApp(const KedaiApp());
}

class KedaiApp extends StatelessWidget {
  const KedaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthViewModel())],
      child: MaterialApp(
        title: 'KedaiApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
