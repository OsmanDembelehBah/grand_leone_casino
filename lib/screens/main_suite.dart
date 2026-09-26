import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../theme/app_theme.dart';

class MainSuiteScreen extends StatefulWidget {
  const MainSuiteScreen({super.key});

  @override
  State<MainSuiteScreen> createState() => _MainSuiteScreenState();
}

class _MainSuiteScreenState extends State<MainSuiteScreen> {
  final DBHelper _dbHelper = DBHelper();
  final TextEditingController _pinController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _currentStaff;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final orders = await _dbHelper.getOrders();
    setState(() {
      _orders = orders;
    });
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    final staff = await _dbHelper.loginEmployee(_pinController.text.trim());
    setState(() {
      _currentStaff = staff;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: const Text('Grand Leone Casino Suite'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    color: AppTheme.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Staff Access',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _pinController,
                            decoration: const InputDecoration(
                              labelText: 'Enter Staff PIN',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentOrange,
                            ),
                            child: const Text('Authenticate'),
                          ),
                          if (_currentStaff != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Logged in as: ${_currentStaff!['name']} (${_currentStaff!['role']})',
                              style:
                                  const TextStyle(color: AppTheme.successGreen),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: AppTheme.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Orders (${_orders.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Divider(color: AppTheme.lightBlueAccent),
                          ..._orders.take(5).map(
                                (o) => ListTile(
                                  title: Text(
                                      'Order #${o['id']} - Zone: ${o['zone'] ?? 'Main'}'),
                                  subtitle:
                                      Text('Timestamp: ${o['timestamp']}'),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
