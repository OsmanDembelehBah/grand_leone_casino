import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';

class MainNavigation extends StatefulWidget {
  final Map<String, dynamic> currentStaff;
  const MainNavigation({super.key, required this.currentStaff});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    bool isManagement = widget.currentStaff['role'] == 'Manager' || widget.currentStaff['role'] == 'Supervisor';

    List<Widget> screens = [
      OrderEntryTab(currentStaff: widget.currentStaff),
      if (isManagement) AnalyticsTab(),
      if (isManagement) StaffManagementTab(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFFF5200),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.local_bar), label: 'Order Entry'),
            if (isManagement) const BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
            if (isManagement) const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Staff Directory'),
          ],
        ),
      ),
    );
  }
}

// ==================== 1. ORDER ENTRY TAB ====================
class OrderEntryTab extends StatefulWidget {
  final Map<String, dynamic> currentStaff;
  const OrderEntryTab({super.key, required this.currentStaff});

  @override
  State<OrderEntryTab> createState() => _OrderEntryTabState();
}

class _OrderEntryTabState extends State<OrderEntryTab> {
  List<Map<String, dynamic>> _drinks = [];
  Map<String, dynamic>? _selectedDrink;
  String _customerType = 'Standard';
  String _selectedZone = 'Main Gaming Floor';
  int _quantity = 1;
  bool _isCustomDrink = false;

  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _customDrinkController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: '15.0');
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDrinks();
  }

  Future<void> _loadDrinks() async {
    final list = await DBHelper().getDrinks();
    setState(() {
      _drinks = list;
      if (_drinks.isNotEmpty) _selectedDrink = _drinks.first;
    });
  }

  Future<void> _submitOrder() async {
    final customerName = _customerController.text.trim().isEmpty ? 'Walk-in Guest' : _customerController.text.trim();
    final drinkName = _isCustomDrink ? _customDrinkController.text.trim() : (_selectedDrink?['name'] ?? 'Custom Beverage');
    final double unitPrice = _isCustomDrink ? (double.tryParse(_priceController.text) ?? 10.0) : (_selectedDrink?['price'] ?? 0.0);
    final double totalPrice = unitPrice * _quantity;
    final orderRef = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    if (drinkName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a drink name.')));
      return;
    }

    final orderData = {
      'orderRef': orderRef,
      'staffId': widget.currentStaff['id'],
      'staffName': widget.currentStaff['name'],
      'customerName': customerName,
      'customerType': _customerType,
      'zone': _selectedZone,
      'category': _isCustomDrink ? 'Custom Drink' : (_selectedDrink?['category'] ?? 'General'),
      'drinkName': drinkName,
      'unitPrice': unitPrice,
      'quantity': _quantity,
      'totalPrice': totalPrice,
      'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'notes': _notesController.text.trim(),
    };

    int result = await DBHelper().insertOrder(orderData);

    if (result > 0 && mounted) {
      _customDrinkController.clear();
      _customerController.clear();
      _notesController.clear();
      setState(() => _quantity = 1);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFFFF5200)),
              SizedBox(width: 8),
              Text('Order Confirmed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('Order #$orderRef successfully logged to database.\nTotal: \$${totalPrice.toStringAsFixed(2)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFFFF5200))),
            ),
          ],
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
        title: Row(
          children: [
            const Icon(Icons.casino, color: Color(0xFFFF5200)),
            const SizedBox(width: 8),
            Text('GRAND LEONE BAR', style: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Staff Profile Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.currentStaff['photoUrl'] ?? '')),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.currentStaff['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${widget.currentStaff['role']} • Active Shift', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer Name & Tier
            TextField(
              controller: _customerController,
              decoration: InputDecoration(
                hintText: 'Customer / Guest Name',
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFFF5200)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ['Standard', 'VIP', 'High Roller'].map((tier) {
                bool isSelected = _customerType == tier;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ChoiceChip(
                      label: Text(tier, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12)),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFF5200),
                      backgroundColor: Colors.white,
                      onSelected: (val) => setState(() => _customerType = tier),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Mode Selector: Catalog vs Custom
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: !_isCustomDrink ? const Color(0xFFFF5200) : Colors.grey.shade300),
                      backgroundColor: !_isCustomDrink ? const Color(0xFFFFF3E0) : Colors.white,
                    ),
                    onPressed: () => setState(() => _isCustomDrink = false),
                    child: const Text('Catalog Drinks', style: TextStyle(color: Color(0xFFFF5200))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _isCustomDrink ? const Color(0xFFFF5200) : Colors.grey.shade300),
                      backgroundColor: _isCustomDrink ? const Color(0xFFFFF3E0) : Colors.white,
                    ),
                    onPressed: () => setState(() => _isCustomDrink = true),
                    child: const Text('Custom Order', style: TextStyle(color: Color(0xFFFF5200))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (!_isCustomDrink) ...[
              const Text('Select Beverage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _drinks.length,
                  itemBuilder: (context, i) {
                    final item = _drinks[i];
                    bool isSelected = _selectedDrink?['id'] == item['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDrink = item),
                      child: Container(
                        width: 110,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? const Color(0xFFFF5200) : Colors.transparent, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(item['imageUrl'], height: 45, errorBuilder: (_, __, ___) => const Icon(Icons.local_bar, color: Color(0xFFFF5200))),
                            const SizedBox(height: 6),
                            Text(item['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            Text('\$${item['price']}', style: const TextStyle(color: Color(0xFFFF5200), fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              TextField(
                controller: _customDrinkController,
                decoration: InputDecoration(
                  hintText: 'Custom Drink Name',
                  prefixIcon: const Icon(Icons.local_bar, color: Color(0xFFFF5200)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Unit Price (\$)',
                  prefixIcon: const Icon(Icons.attach_money, color: Color(0xFFFF5200)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Quantity & Confirm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove, color: Color(0xFFFF5200)), onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1)),
                      Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      IconButton(icon: const Icon(Icons.add, color: Color(0xFFFF5200)), onPressed: () => setState(() => _quantity++)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5200), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('CONFIRM & LOG ORDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: _submitOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 2. ANALYTICS TAB ====================
class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final list = await DBHelper().getOrders();
    setState(() {
      _orders = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFF5200))));
    }

    double totalRevenue = _orders.fold(0.0, (sum, item) => sum + (item['totalPrice'] ?? 0.0));
    int totalDrinks = _orders.fold(0, (sum, item) => sum + ((item['quantity'] as int?) ?? 0));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('SUPERVISOR DASHBOARD', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Color(0xFFFF5200)), onPressed: _fetchOrders)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _metricTile('Total Revenue', '\$${totalRevenue.toStringAsFixed(2)}', Icons.payments, Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _metricTile('Drinks Served', '$totalDrinks', Icons.local_bar, const Color(0xFFFF5200))),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Live Audit Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orders.length,
              itemBuilder: (context, i) {
                final o = _orders[i];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text('${o['drinkName']} (x${o['quantity']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('Ref: ${o['orderRef']} | Guest: ${o['customerName']}\nBartender: ${o['staffName']} | ${o['timestamp']}', style: const TextStyle(fontSize: 11)),
                    trailing: Text('\$${o['totalPrice']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF5200))),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}

// ==================== 3. STAFF MANAGEMENT TAB ====================
class StaffManagementTab extends StatefulWidget {
  const StaffManagementTab({super.key});

  @override
  State<StaffManagementTab> createState() => _StaffManagementTabState();
}

class _StaffManagementTabState extends State<StaffManagementTab> {
  List<Map<String, dynamic>> _staffList = [];

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    final list = await DBHelper().getAllStaff();
    setState(() => _staffList = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('STAFF DIRECTORY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _staffList.length,
        itemBuilder: (context, i) {
          final s = _staffList[i];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(s['photoUrl'])),
              title: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${s['role']} • ${s['email']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(s['status'], style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }
}
