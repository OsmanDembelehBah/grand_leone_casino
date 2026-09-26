import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/drink_log.dart';
import 'dashboard_screen.dart';
import 'log_drink_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final VoidCallback onLogout;

  const MainNavigationScreen({super.key, this.user, required this.onLogout});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<DrinkLog> _logs = [
    DrinkLog(
      id: 'ORD-101',
      drinkName: 'Fanta',
      category: 'Soda',
      station: 'Main Floor',
      location: 'Table 12',
      quantity: 1,
      loggedBy: 'Alhaji Osman Bah',
      role: 'Manager',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  void _addLog(DrinkLog log) {
    setState(() {
      _logs.insert(0, log);
    });
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(
        logs: _logs,
        user: widget.user,
        onNavigateToLog: () => _navigateToTab(1),
      ),
      LogDrinkScreen(
        user: widget.user,
        onLogAdded: (newLog) {
          _addLog(newLog);
          _navigateToTab(0);
        },
      ),
      _buildAnalyticsTab(),
      _buildHistoryTab(),
      ProfileScreen(user: widget.user, onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.accentOrange,
        unselectedItemColor: AppTheme.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: _navigateToTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_bar_outlined),
            activeIcon: Icon(Icons.local_bar),
            label: 'Log Drink',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.analytics, color: AppTheme.accentOrange),
                title: const Text('Total Drinks Served Today'),
                trailing: Text('${_logs.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.lightBlueAccent,
                child: Icon(Icons.local_drink, color: AppTheme.primaryNavy),
              ),
              title: Text('${log.quantity}x ${log.drinkName}'),
              subtitle: Text('${log.loggedBy} • ${log.station} (${log.location})'),
              trailing: Text(
                '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}
