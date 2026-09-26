import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  final Function(Map<String, dynamic>)? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 64, color: AppTheme.accentOrange),
              const SizedBox(height: 16),
              const Text(
                'Grand Leone Staff Portal',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (onLoginSuccess != null) {
                    onLoginSuccess!({'name': 'Manager', 'role': 'Admin'});
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange),
                child: const Text('Access Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
