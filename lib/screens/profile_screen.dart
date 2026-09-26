import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(title: const Text('Staff Profile')),
      body: const Center(
        child: Text('Profile Details',
            style: TextStyle(color: AppTheme.textPrimary)),
      ),
    );
  }
}
