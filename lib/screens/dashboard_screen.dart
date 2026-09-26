import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/drink_log.dart';

class DashboardScreen extends StatefulWidget {
  final List<DrinkLog> logs;
  final Map<String, dynamic>? user;
  final VoidCallback onNavigateToLog;

  const DashboardScreen({
    super.key,
    required this.logs,
    this.user,
    required this.onNavigateToLog,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedStation = 'Grand Leone Main Floor';

  @override
  Widget build(BuildContext context) {
    final userName = widget.user?['name'] ?? 'Alhaji Osman Bah';
    final userRole = widget.user?['role'] ?? 'Manager';
    final avatar = widget.user?['avatar'] ?? '👨‍💼';

    return Scaffold(
      backgroundColor: AppTheme.scaffoldLightBg,
      appBar: AppBar(
        toolbarHeight: 65,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white12,
              radius: 18,
              child: Text(avatar, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(userRole, style: const TextStyle(fontSize: 10, color: AppTheme.accentOrange)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new alerts for this shift.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStation,
                  dropdownColor: AppTheme.primaryNavy,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedStation = newValue);
                    }
                  },
                  items: <String>['Grand Leone Main Floor', 'VIP Lounge', 'Table Games', 'Slot Machines']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: [
                _buildStatCard('Today\'s Servings', '${widget.logs.length}', '+100%', Icons.local_drink_outlined, Colors.orange),
                _buildStatCard('Drinks Served', '${widget.logs.fold<int>(0, (sum, item) => sum + item.quantity)}', '+20%', Icons.wine_bar_outlined, Colors.blue),
                _buildStatCard('Active Staff', '6', 'Shift active', Icons.groups_outlined, Colors.green),
                _buildStatCard('Stations', '4', 'Operational', Icons.storefront_outlined, Colors.purple),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Live Activity Feed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
                Text('${widget.logs.length} logged', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),

            ...widget.logs.take(5).map((log) => _buildActivityItem(log)),

            const SizedBox(height: 16),
            const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.add_circle_outline, 'Log Drink', AppTheme.accentOrange, widget.onNavigateToLog),
                _buildActionButton(Icons.history, 'Shift Logs', Colors.indigo, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All logs up to date.')),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtext, IconData icon, Color color) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text(subtext, style: const TextStyle(fontSize: 8, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(DrinkLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.accentOrange.withValues(alpha: 0.1),
          child: Text(log.loggedBy[0], style: const TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        title: Row(
          children: [
            Text(log.loggedBy, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text(log.role, style: const TextStyle(fontSize: 7, color: AppTheme.accentOrange, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        subtitle: Text('Served ${log.quantity}x ${log.drinkName} (${log.location})', style: const TextStyle(fontSize: 10, color: AppTheme.textPrimary)),
        trailing: Text('${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
