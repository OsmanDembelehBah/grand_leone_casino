import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'log_drink_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final Map<String, dynamic>? user;

  const MainNavigationScreen({super.key, this.user});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final String _selectedZone = 'VIP Lounge';

  static const List<Widget> _pages = [
    DashboardScreen(),
    LogDrinkScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: AppTheme.accentOrange,
        unselectedItemColor: AppTheme.textSecondary,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: 'Dashboard ($_selectedZone)',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_bar),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
