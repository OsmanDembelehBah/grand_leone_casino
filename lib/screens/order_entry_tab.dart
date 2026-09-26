import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrderEntryTab extends StatefulWidget {
  const OrderEntryTab({super.key});

  @override
  State<OrderEntryTab> createState() => _OrderEntryTabState();
}

class _OrderEntryTabState extends State<OrderEntryTab> {
  String _selectedCategory = 'Spirits';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            dropdownColor: AppTheme.cardColor,
            decoration: const InputDecoration(
              labelText: 'Select Drink Category',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Spirits', child: Text('Spirits')),
              DropdownMenuItem(value: 'Wine', child: Text('Wine')),
              DropdownMenuItem(value: 'Beer', child: Text('Beer')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
        ],
      ),
    );
  }
}
