import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  final StreamController<void> _dbChangeController =
      StreamController<void>.broadcast();
  Stream<void> get onDatabaseChanged => _dbChangeController.stream;

  factory DBHelper() => _instance;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'grand_leone_casino.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE staff (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        pin TEXT,
        role TEXT,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE drinks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        drink_id INTEGER,
        staff_id INTEGER,
        quantity INTEGER,
        zone TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE activity_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT,
        details TEXT,
        timestamp TEXT
      )
    ''');

    // Seed Data
    await db.insert('staff',
        {'name': 'Manager', 'pin': '1234', 'role': 'Admin', 'image_path': ''});
    await db.insert(
        'drinks', {'name': 'Whiskey', 'price': 15.0, 'category': 'Spirits'});
  }

  void _notifyListeners() {
    _dbChangeController.add(null);
  }

  // Flexibly accepts either loginEmployee(pin) or loginEmployee(pin, role)
  Future<Map<String, dynamic>?> loginEmployee(String pin,
      [String? role]) async {
    final db = await database;
    List<Map<String, dynamic>> results;
    if (role != null && role.isNotEmpty) {
      results = await db.query('staff',
          where: 'pin = ? AND role = ?', whereArgs: [pin, role]);
    } else {
      results = await db.query('staff', where: 'pin = ?', whereArgs: [pin]);
    }
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> authenticateStaff(String pin,
      [String? extra]) async {
    return await loginEmployee(pin, extra);
  }

  Future<int> registerEmployee(Map<String, dynamic> staffData) async {
    final db = await database;
    int id = await db.insert('staff', staffData);
    _notifyListeners();
    return id;
  }

  Future<List<Map<String, dynamic>>> getDrinks() async {
    final db = await database;
    return await db.query('drinks');
  }

  Future<List<Map<String, dynamic>>> getAllStaff() async {
    final db = await database;
    return await db.query('staff');
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await database;
    return await db.query('orders', orderBy: 'id DESC');
  }

  Future<int> insertOrder(dynamic orderData) async {
    final db = await database;
    Map<String, dynamic> row = orderData is Map<String, dynamic>
        ? orderData
        : {'timestamp': DateTime.now().toIso8601String()};
    int id = await db.insert('orders', row);
    _notifyListeners();
    return id;
  }

  Future<int> logOrder(dynamic orderData) async {
    return await insertOrder(orderData);
  }

  // Accepts either a String or a File object
  Future<String> saveImageToPersistentStorage(dynamic imageInput) async {
    if (imageInput == null) return '';
    if (imageInput is String) return imageInput;
    return imageInput.path;
  }

  Future<List<Map<String, dynamic>>> getActivityHistory() async {
    final db = await database;
    return await db.query('activity_history', orderBy: 'id DESC');
  }
}
