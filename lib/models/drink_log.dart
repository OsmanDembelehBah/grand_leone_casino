class DrinkLog {
  final String id;
  final String drinkName;
  final String category;
  final String station;
  final String location;
  final int quantity;
  final String loggedBy;
  final String role;
  final DateTime timestamp;

  DrinkLog({
    required this.id,
    required this.drinkName,
    required this.category,
    required this.station,
    required this.location,
    required this.quantity,
    required this.loggedBy,
    required this.role,
    required DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
