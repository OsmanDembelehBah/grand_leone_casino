import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';

// Helper Widget to display profile image from Local File Path or Network Fallback
Widget buildProfileAvatar(String photoPath, {double radius = 24}) {
  if (photoPath.isNotEmpty && File(photoPath).existsSync()) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: FileImage(File(photoPath)),
    );
  }
  return CircleAvatar(
    radius: radius,
    backgroundColor: const Color(0xFFFF5200),
    child: Icon(Icons.person, color: Colors.white, size: radius),
  );
}

// ==================== AUTH & REGISTRATION ====================
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Map<String, dynamic>? _currentEmployee;
  bool _isRegistering = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Registration Controllers
  final TextEditingController _regName = TextEditingController();
  final TextEditingController _regEmail = TextEditingController();
  final TextEditingController _regPassword = TextEditingController();
  final TextEditingController _regAddress = TextEditingController();
  String _selectedRole = 'Bartender';
  File? _selectedImageFile;

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleLogin() async {
    final user = await DBHelper().loginEmployee(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user != null) {
      setState(() => _currentEmployee = user);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials. Check email and password.')),
        );
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_regName.text.isEmpty || _regEmail.text.isEmpty || _regPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    String photoPath = '';
    if (_selectedImageFile != null) {
      photoPath = await DBHelper().saveImageToPersistentStorage(_selectedImageFile!);
    }

    final newEmployee = {
      'name': _regName.text.trim(),
      'email': _regEmail.text.trim(),
      'password': _regPassword.text.trim(),
      'address': _regAddress.text.trim().isEmpty ? 'Freetown' : _regAddress.text.trim(),
      'role': _selectedRole,
      'photoPath': photoPath,
      'status': 'Active',
      'joinedDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };

    try {
      await DBHelper().registerEmployee(newEmployee);
      setState(() => _isRegistering = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please sign in.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed: Email may already exist.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentEmployee != null) {
      return MainSuiteNavigation(
        currentEmployee: _currentEmployee!,
        onLogout: () => setState(() => _currentEmployee = null),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.casino, size: 56, color: Color(0xFFFF5200)),
              const SizedBox(height: 8),
              Text(
                'GRAND LEONE CASINO',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900], letterSpacing: 1.2),
              ),
              Text('Jackpot 777 Internal System', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 32),

              if (!_isRegistering) ...[
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Employee Email',
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFF5200)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFF5200)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _handleLogin,
                    child: const Text('SIGN IN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isRegistering = true),
                  child: const Text('New Employee? Register Here', style: TextStyle(color: Color(0xFFFF5200))),
                ),
              ] else ...[
                // Profile Photo Upload Picker
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _selectedImageFile != null ? FileImage(_selectedImageFile!) : null,
                    child: _selectedImageFile == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Color(0xFFFF5200), size: 24),
                              Text('Photo', style: TextStyle(fontSize: 10, color: Colors.black54)),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _regName,
                  decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regEmail,
                  decoration: InputDecoration(labelText: 'Email Address', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regPassword,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regAddress,
                  decoration: InputDecoration(labelText: 'Address', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: ['Bartender', 'Supervisor', 'Manager'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedRole = val!),
                  decoration: InputDecoration(labelText: 'Role', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5200), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _handleRegister,
                    child: const Text('CREATE ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isRegistering = false),
                  child: const Text('Back to Login', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== MAIN 5-TAB NAVIGATION ====================
class MainSuiteNavigation extends StatefulWidget {
  final Map<String, dynamic> currentEmployee;
  final VoidCallback onLogout;

  const MainSuiteNavigation({super.key, required this.currentEmployee, required this.onLogout});

  @override
  State<MainSuiteNavigation> createState() => _MainSuiteNavigationState();
}

class _MainSuiteNavigationState extends State<MainSuiteNavigation> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardTab(employee: widget.currentEmployee),
      OrderEntryTextTab(employee: widget.currentEmployee),
      const HistoryTab(),
      const AnalyticsTab(),
      ProfileTab(employee: widget.currentEmployee, onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF5200),
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Log Drink'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==================== 1. REAL-TIME DASHBOARD TAB ====================
class DashboardTab extends StatelessWidget {
  final Map<String, dynamic> employee;
  const DashboardTab({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('CASINO LIVE MONITOR', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: StreamBuilder<void>(
        stream: DBHelper().onDatabaseChanged,
        builder: (context, _) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: DBHelper().getOrders(),
            builder: (context, snapshot) {
              final orders = snapshot.data ?? [];
              int totalDrinksServed = orders.fold(0, (sum, order) => sum + ((order['quantity'] as int?) ?? 0));

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _metricCard('Servings Logged', '${orders.length}', Icons.receipt_long, const Color(0xFFFF5200))),
                        const SizedBox(width: 12),
                        Expanded(child: _metricCard('Total Drinks Served', '$totalDrinksServed', Icons.local_bar, Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _metricCard('Active Station', 'Grand Leone / 777', Icons.casino, Colors.green)),
                        const SizedBox(width: 12),
                        Expanded(child: _metricCard('Role', employee['role'], Icons.badge, Colors.purple)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Live Activity Feed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: orders.isEmpty
                            ? const Center(child: Text('No drinks served yet today.'))
                            : ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (context, i) {
                                  final o = orders[i];
                                  return ListTile(
                                    leading: buildProfileAvatar(o['employeePhoto'] ?? '', radius: 18),
                                    title: Text('${o['quantity']}x ${o['orderedItem']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('Guest: ${o['customerName']} • Served by: ${o['employeeName']}'),
                                    trailing: Text(o['timestamp'] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _metricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}

// ==================== 2. TEXT-BASED DRINK LOGGING TAB ====================
class OrderEntryTextTab extends StatefulWidget {
  final Map<String, dynamic> employee;
  const OrderEntryTextTab({super.key, required this.employee});

  @override
  State<OrderEntryTextTab> createState() => _OrderEntryTextTabState();
}

class _OrderEntryTextTabState extends State<OrderEntryTextTab> {
  final TextEditingController _orderedItemController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  int _quantity = 1;

  Future<void> _submitOrder() async {
    final orderedItem = _orderedItemController.text.trim();
    if (orderedItem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter what drink was ordered.')),
      );
      return;
    }

    final customerName = _customerController.text.trim().isEmpty ? 'Walk-in Player' : _customerController.text.trim();
    final orderRef = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final orderData = {
      'orderRef': orderRef,
      'employeeId': widget.employee['id'],
      'employeeName': widget.employee['name'],
      'employeePhoto': widget.employee['photoPath'] ?? '',
      'customerName': customerName,
      'orderedItem': orderedItem,
      'quantity': _quantity,
      'timestamp': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      'notes': _notesController.text.trim(),
    };

    await DBHelper().logOrder(orderData);

    if (mounted) {
      _orderedItemController.clear();
      _customerController.clear();
      _notesController.clear();
      setState(() => _quantity = 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged $orderedItem for $customerName successfully!'),
          backgroundColor: const Color(0xFFFF5200),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('LOG PLAYER DRINK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Staff Profile Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  buildProfileAvatar(widget.employee['photoPath'] ?? ''),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.employee['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${widget.employee['role']} • Active Station', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // What was ordered? Input
            const Text('What drink was requested?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _orderedItemController,
              decoration: InputDecoration(
                hintText: 'Type drink name (e.g. Heineken, Hennessy, Water)...',
                prefixIcon: const Icon(Icons.local_bar, color: Color(0xFFFF5200)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // Player/Customer Name
            const Text('Player / Customer Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _customerController,
              decoration: InputDecoration(
                hintText: 'Enter player name or table/machine #...',
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFFF5200)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Counter
            const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              height: 58,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(icon: const Icon(Icons.remove, color: Color(0xFFFF5200)), onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1)),
                  Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(icon: const Icon(Icons.add, color: Color(0xFFFF5200)), onPressed: () => setState(() => _quantity++)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            const Text('Notes / Machine Location (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Extra ice, VIP section, Machine #12...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('SUBMIT DRINK LOG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: _submitOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 3. REAL-TIME HISTORY TAB ====================
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('AUDIT & ACTIVITY HISTORY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: StreamBuilder<void>(
        stream: DBHelper().onDatabaseChanged,
        builder: (context, _) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: DBHelper().getActivityHistory(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFFF5200)));
              final logs = snapshot.data!;

              if (logs.isEmpty) {
                return const Center(child: Text('No activity logged yet.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, i) {
                  final log = logs[i];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildProfileAvatar(log['employeePhoto'] ?? ''),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log['employeeName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(log['action'], style: const TextStyle(color: Color(0xFFFF5200), fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(log['details'], style: TextStyle(color: Colors.grey[800], fontSize: 12)),
                                const SizedBox(height: 6),
                                Text(log['timestamp'], style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ==================== 4. ANALYTICS TAB ====================
class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('QUANTITY ANALYTICS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: StreamBuilder<void>(
        stream: DBHelper().onDatabaseChanged,
        builder: (context, _) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: DBHelper().getOrders(),
            builder: (context, snapshot) {
              final orders = snapshot.data ?? [];
              Map<String, int> drinkCounts = {};
              for (var o in orders) {
                String drink = o['orderedItem'] ?? 'Unknown';
                int qty = (o['quantity'] as int?) ?? 1;
                drinkCounts[drink] = (drinkCounts[drink] ?? 0) + qty;
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Most Requested Drinks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),
                        if (drinkCounts.isEmpty)
                          const Text('No drink analytics recorded yet.')
                        else
                          ...drinkCounts.entries.map((e) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFFFF5200).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Text('${e.value} served', style: const TextStyle(color: Color(0xFFFF5200), fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ==================== 5. PROFILE TAB ====================
class ProfileTab extends StatelessWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onLogout;

  const ProfileTab({super.key, required this.employee, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('EMPLOYEE PROFILE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  buildProfileAvatar(employee['photoPath'] ?? '', radius: 45),
                  const SizedBox(height: 12),
                  Text(employee['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(employee['role'], style: const TextStyle(color: Color(0xFFFF5200), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(leading: const Icon(Icons.email_outlined), title: const Text('Email'), subtitle: Text(employee['email'])),
                  const Divider(height: 1),
                  ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text('Address'), subtitle: Text(employee['address'])),
                  const Divider(height: 1),
                  ListTile(leading: const Icon(Icons.verified_user_outlined), title: const Text('Status'), subtitle: Text(employee['status'])),
                  const Divider(height: 1),
                  ListTile(leading: const Icon(Icons.calendar_today_outlined), title: const Text('Joined Date'), subtitle: Text(employee['joinedDate'])),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('SIGN OUT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onPressed: onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
