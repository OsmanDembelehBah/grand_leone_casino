import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/order_model.dart';

class OrderEntryTab extends StatefulWidget {
  final Map<String, dynamic> currentStaff;
  const OrderEntryTab({super.key, required this.currentStaff});

  @override
  State<OrderEntryTab> createState() => _OrderEntryTabState();
}

class _OrderEntryTabState extends State<OrderEntryTab> {
  String _customerType = 'Standard';
  String _selectedZone = 'Main Gaming Floor';
  String _selectedCategory = 'Spirits & Wine';

  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _customDrinkController = TextEditingController();

  final Map<String, List<String>> _drinkCatalog = {
    'Spirits & Wine': ['Dom Pérignon Champagne', 'Hennessy XO Cognac', 'Macallan 18 Single Malt'],
    'Cocktails & Premium Mixes': ['Casino Royale Martini', 'Old Fashioned Gold', 'Mojito Supreme'],
    'Soft & Energy': ['Red Bull Energy', 'Sparkling Mineral Water', 'Fresh Orange Juice']
  };

  late String _selectedDrink;
  int _quantity = 1;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDrink = _drinkCatalog[_selectedCategory]!.first;
  }

  Future<void> _submitOrder() async {
    setState(() => _isSubmitting = true);

    final finalDrinkName = _customDrinkController.text.trim().isNotEmpty
        ? _customDrinkController.text.trim()
        : _selectedDrink;

    final finalCustomerName = _customerController.text.trim().isNotEmpty
        ? _customerController.text.trim()
        : 'Walk-in Guest';

    final order = DrinkOrder(
      bartenderName: widget.currentStaff['name'] ?? 'Staff User',
      customerName: finalCustomerName,
      customerType: _customerType,
      zone: _selectedZone,
      category: _selectedCategory,
      drinkName: finalDrinkName,
      quantity: _quantity,
      timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );

    int result = await DBHelper().insertOrder(order);

    setState(() => _isSubmitting = false);

    if (result > 0 && mounted) {
      _customDrinkController.clear();
      _customerController.clear();
      setState(() => _quantity = 1);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #$result logged successfully into SQLite!'),
          backgroundColor: Colors.deepOrange,
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
            Image.asset('assets/images/logo.png', height: 30, errorBuilder: (_, __, ___) => const Icon(Icons.casino, color: Colors.deepOrange)),
            const SizedBox(width: 10),
            const Text('NEW DRINK ORDER', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  CircleAvatar(radius: 24, backgroundImage: NetworkImage(widget.currentStaff['photoUrl'] ?? '')),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.currentStaff['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(widget.currentStaff['role'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _customerController,
              decoration: InputDecoration(
                hintText: 'Customer / Guest Name',
                prefixIcon: const Icon(Icons.person, color: Colors.deepOrange),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: ['Standard', 'VIP', 'High Roller'].map((tier) {
                bool isSelected = _customerType == tier;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Center(child: Text(tier, style: TextStyle(color: isSelected ? Colors.white : Colors.black87))),
                      selected: isSelected,
                      selectedColor: Colors.deepOrange,
                      backgroundColor: Colors.white,
                      onSelected: (val) => setState(() => _customerType = tier),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedZone,
              decoration: InputDecoration(labelText: 'Zone', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              items: ['Main Gaming Floor', 'VIP Private Lounge', 'Roulette Tables', 'Poker Salon'].map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
              onChanged: (val) => setState(() => _selectedZone = val!),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: 'Category', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              items: _drinkCatalog.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val!;
                  _selectedDrink = _drinkCatalog[_selectedCategory]!.first;
                });
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _selectedDrink,
              decoration: InputDecoration(labelText: 'Select Drink', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              items: _drinkCatalog[_selectedCategory]!.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => _selectedDrink = val!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customDrinkController,
              decoration: InputDecoration(
                hintText: 'Or type custom drink name...',
                prefixIcon: const Icon(Icons.local_bar, color: Colors.deepOrange),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove, color: Colors.deepOrange), onPressed: () => setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1)),
                      Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(icon: const Icon(Icons.add, color: Colors.deepOrange), onPressed: () => setState(() => _quantity++)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text('CONFIRM & LOG ORDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: _isSubmitting ? null : _submitOrder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
