import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/drink_log.dart';

class LogDrinkScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Function(DrinkLog) onLogAdded;

  const LogDrinkScreen({super.key, this.user, required this.onLogAdded});

  @override
  State<LogDrinkScreen> createState() => _LogDrinkScreenState();
}

class _LogDrinkScreenState extends State<LogDrinkScreen> {
  String _selectedDrink = 'Heineken';
  String _selectedStation = 'Grand Leone Main Floor';
  final TextEditingController _locationController = TextEditingController(text: 'Table 5');
  int _quantity = 1;

  final List<String> _drinks = ['Heineken', 'Fanta', 'Coke', 'Red Bull', 'Water', 'Whiskey'];

  void _submitLog() {
    final newLog = DrinkLog(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      drinkName: _selectedDrink,
      category: 'Beverage',
      station: _selectedStation,
      location: _locationController.text.trim(),
      quantity: _quantity,
      loggedBy: widget.user?['name'] ?? 'Alhaji Osman Bah',
      role: widget.user?['role'] ?? 'Manager',
      timestamp: DateTime.now(),
    );

    widget.onLogAdded(newLog);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully logged ${_quantity}x $_selectedDrink!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldLightBg,
      appBar: AppBar(title: const Text('Log Complimentary Drink')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Drink', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _drinks.map((drink) {
                final isSelected = _selectedDrink == drink;
                return ChoiceChip(
                  label: Text(drink),
                  selected: isSelected,
                  selectedColor: AppTheme.accentOrange,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textPrimary, fontSize: 11),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedDrink = drink);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const Text('Station', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedStation,
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              items: ['Grand Leone Main Floor', 'VIP Section', 'Table Games', 'Machines']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                  .toList(),
              onChanged: (val) => setState(() => _selectedStation = val!),
            ),
            const SizedBox(height: 16),

            const Text('Customer / Table / Machine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g. Table 12 or Machine #4'),
            ),
            const SizedBox(height: 16),

            const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _submitLog,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentOrange),
                child: const Text('Submit Drink Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
