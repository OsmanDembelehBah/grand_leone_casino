import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? user;
  final VoidCallback? onLogout;

  const ProfileScreen({super.key, this.user, this.onLogout});

  @override
  Widget build(BuildContext context) {
    final avatar = user?['avatar'] ?? '👨‍💼';
    final name = user?['name'] ?? 'Alhaji Osman Bah';
    final role = user?['role'] ?? 'Manager';
    final email = user?['email'] ?? 'osman@grandleone.com';

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryNavy,
              child: Text(avatar, style: const TextStyle(fontSize: 36)),
            ),
            const SizedBox(height: 12),
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(role, style: const TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 30),
            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.badge, color: AppTheme.primaryNavy),
                    title: Text('Employee ID'),
                    trailing: Text('GL-8821', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.schedule, color: AppTheme.primaryNavy),
                    title: Text('Current Shift'),
                    trailing: Text('Night Shift (18:00 - 02:00)', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('LOG OUT OF SHIFT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
