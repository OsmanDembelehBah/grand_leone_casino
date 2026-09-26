import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LogDrinkScreen extends StatelessWidget {
  const LogDrinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: const Text('Log Drink Order'),
      ),
      body: const Center(
        child: Text(
          'Drink Logging System',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 18),
        ),
      ),
    );
  }
}
