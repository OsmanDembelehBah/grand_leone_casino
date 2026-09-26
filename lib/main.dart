import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_suite.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GrandLeoneApp());
}

class GrandLeoneApp extends StatelessWidget {
  const GrandLeoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grand Leone Casino',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainSuiteScreen(),
    );
  }
}
