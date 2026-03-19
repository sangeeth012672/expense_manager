import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE categories ADD COLUMN user_phone TEXT');
      await db.execute('ALTER TABLE transactions ADD COLUMN user_phone TEXT');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const numType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';
    
    // Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        user_phone TEXT,
        is_synced $intType,
        is_deleted $intType
      )
    ''');

    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        amount $numType,
        note $textType,
        type $textType,
        category_id TEXT,
        user_phone TEXT,
        is_synced $intType,
        is_deleted $intType,
        timestamp $textType,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('transactions');
    await db.delete('categories');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
