class DrinkOrder {
  final int? id;
  final String bartenderName;
  final String customerName;
  final String customerType;
  final String zone;
  final String category;
  final String drinkName;
  final int quantity;
  final String timestamp;

  DrinkOrder({
    this.id,
    required this.bartenderName,
    required this.customerName,
    required this.customerType,
    required this.zone,
    required this.category,
    required this.drinkName,
    required this.quantity,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bartenderName': bartenderName,
      'customerName': customerName,
      'customerType': customerType,
      'zone': zone,
      'category': category,
      'drinkName': drinkName,
      'quantity': quantity,
      'timestamp': timestamp,
    };
  }

  factory DrinkOrder.fromMap(Map<String, dynamic> map) {
    return DrinkOrder(
      id: map['id'],
      bartenderName: map['bartenderName'] ?? '',
      customerName: map['customerName'] ?? 'Walk-in Guest',
      customerType: map['customerType'] ?? 'Standard',
      zone: map['zone'] ?? 'Main Lounge',
      category: map['category'] ?? 'General',
      drinkName: map['drinkName'] ?? '',
      quantity: map['quantity'] ?? 1,
      timestamp: map['timestamp'] ?? '',
    );
  }
}
