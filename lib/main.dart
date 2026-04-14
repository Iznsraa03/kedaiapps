import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/auth_viewmodel.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_shell.dart';

void main() {
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
        home: const MainShell(),
      ),
    );
  }
}
