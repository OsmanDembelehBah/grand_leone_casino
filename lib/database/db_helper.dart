import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  // Real-time synchronization broadcast stream controller
  final StreamController<void> _dbChangeController = StreamController<void>.broadcast();
  Stream<void> get onDatabaseChanged => _dbChangeController.stream;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<Database> _initDB() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'grand_leone_production_v3.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Employees Table
        await db.execute('''
          CREATE TABLE employees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            address TEXT NOT NULL,
            role TEXT NOT NULL,
            photoPath TEXT NOT NULL,
            status TEXT DEFAULT 'Active',
            joinedDate TEXT NOT NULL
          )
        ''');

        // Orders Table (No pricing/revenue fields)
        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderRef TEXT NOT NULL,
            employeeId INTEGER,
            employeeName TEXT NOT NULL,
            employeePhoto TEXT NOT NULL,
            customerName TEXT NOT NULL,
            orderedItem TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            timestamp TEXT NOT NULL,
            notes TEXT
          )
        ''');

        // Activity Log Table
        await db.execute('''
          CREATE TABLE activity_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employeeName TEXT NOT NULL,
            employeePhoto TEXT NOT NULL,
            action TEXT NOT NULL,
            details TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');

        // Seed Default Management Accounts
        String defaultPasswordHash = hashPassword('1234');
        await db.execute('''
          INSERT INTO employees (name, email, password, address, role, photoPath, status, joinedDate) VALUES 
          ('Achmed Thronka', 'achmed@grandleone.com', '$defaultPasswordHash', '15 Wilkinson Road, Freetown', 'Manager', '', 'Active', '2025-01-10'),
          ('Alhaji Bah', 'alhajibah@grandleone.com', '$defaultPasswordHash', '84 Spur Loop, Freetown', 'Bartender', '', 'Active', '2025-03-01')
        ''');
      },
    );
  }

  // --- Image Storage Helper ---
  Future<String> saveImageToPersistentStorage(File srcFile) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(join(docsDir.path, 'profile_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}${extension(srcFile.path)}';
    final savedFile = await srcFile.copy(join(photosDir.path, fileName));
    return savedFile.path;
  }

  // --- Authentication ---
  Future<Map<String, dynamic>?> loginEmployee(String email, String password) async {
    final dbClient = await db;
    String hashedPassword = hashPassword(password);
    
    var res = await dbClient.query(
      'employees',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );

    if (res.isEmpty) {
      res = await dbClient.query(
        'employees',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
    }

    return res.isNotEmpty ? res.first : null;
  }

  Future<int> registerEmployee(Map<String, dynamic> employeeData) async {
    final dbClient = await db;
    Map<String, dynamic> data = Map.from(employeeData);
    data['password'] = hashPassword(data['password']);
    int id = await dbClient.insert('employees', data);
    
    // Notify listeners for real-time dashboard update
    _dbChangeController.add(null);
    return id;
  }

  // --- Order Management ---
  Future<int> logOrder(Map<String, dynamic> orderData) async {
    final dbClient = await db;
    int orderId = await dbClient.insert('orders', orderData);

    // Record system activity entry
    await dbClient.insert('activity_logs', {
      'employeeName': orderData['employeeName'],
      'employeePhoto': orderData['employeePhoto'],
      'action': 'Served ${orderData['quantity']}x ${orderData['orderedItem']}',
      'details': 'Customer: ${orderData['customerName']} • Ref: ${orderData['orderRef']}',
      'timestamp': orderData['timestamp'],
    });

    // Notify listeners for real-time dashboard update
    _dbChangeController.add(null);
    return orderId;
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final dbClient = await db;
    return await dbClient.query('orders', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getActivityHistory() async {
    final dbClient = await db;
    return await dbClient.query('activity_logs', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getEmployees() async {
    final dbClient = await db;
    return await dbClient.query('employees', orderBy: 'id DESC');
  }
}
