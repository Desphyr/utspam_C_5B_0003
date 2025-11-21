import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/car_model.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'car_rent_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        nik TEXT UNIQUE,
        email TEXT,
        telp TEXT,
        alamat TEXT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

  
    await db.execute('''
      CREATE TABLE cars(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        namaMobil TEXT,
        jenisMobil TEXT,
        hargaSewa INTEGER,
        gambar TEXT
      )
    ''');

   
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        carId INTEGER,
        namaPenyewa TEXT,
        lamaSewa INTEGER,
        tanggalMulai TEXT,
        totalHarga INTEGER,
        status TEXT,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (carId) REFERENCES cars(id)
      )
    ''');

    
    await _insertDummyCars(db);
  }


  Future<void> _insertDummyCars(Database db) async {
    final dummyCars = [
      CarModel(
          namaMobil: 'Toyota Avanza',
          jenisMobil: 'MPV',
          hargaSewa: 350000,
          gambar: 'avanza.png'),
      CarModel(
          namaMobil: 'Honda Brio',
          jenisMobil: 'City Car',
          hargaSewa: 300000,
          gambar: 'brio.png'),
      CarModel(
          namaMobil: 'Mitsubishi Pajero',
          jenisMobil: 'SUV',
          hargaSewa: 800000,
          gambar: 'pajero.png'),
      CarModel(
          namaMobil: 'Lamborghini Aventador',
          jenisMobil: 'Supercar',
          hargaSewa: 15000000,
          gambar: 'aventador.png'),
      CarModel(
          namaMobil: 'Bugatti Veyron',
          jenisMobil: 'Hypercar',
          hargaSewa: 25000000,
          gambar: 'veyron.png'),
      CarModel(
          namaMobil: 'Audi R8', 
          jenisMobil: 'Sport Car',
          hargaSewa: 5000000,
          gambar: 'audir8.png'),
    ];

    for (var car in dummyCars) {
      await db.insert('cars', car.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<CarModel>> getAllCars() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cars');
    return List.generate(maps.length, (i) {
      return CarModel.fromMap(maps[i]);
    });
  }

  Future<CarModel?> getCarById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cars',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return CarModel.fromMap(maps.first);
    }
    return null;
  }


  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }
  

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByUsername(String loginId, String password) async {
    final db = await database;
 
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: '(username = ? OR nik = ?) AND password = ?',
      whereArgs: [loginId, loginId, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }


  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllTransactions(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.*,
        c.namaMobil,
        c.jenisMobil,
        c.hargaSewa
      FROM transactions t
      JOIN cars c ON t.carId = c.id
      WHERE t.userId = ?
      ORDER BY t.id DESC
    ''', [userId]);

    return maps;
  }

  Future<Map<String, dynamic>?> getTransactionDetail(int transactionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        t.*,
        c.namaMobil,
        c.jenisMobil,
        c.hargaSewa,
        c.gambar
      FROM transactions t
      JOIN cars c ON t.carId = c.id
      WHERE t.id = ?
    ''', [transactionId]);

    return maps.isNotEmpty ? maps.first : null;
  }
}