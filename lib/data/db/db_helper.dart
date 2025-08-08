import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _db;
  Future<Database> get database async => _db ??= await initDb();

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'statements_app.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      account_number TEXT,
      currency TEXT,
      is_primary INTEGER DEFAULT 0,
      balance REAL DEFAULT 0
    );''');

    await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      monthly_budget REAL DEFAULT 0,
      icon_id INTEGER,
      color TEXT
    );''');

    await db.execute('''
    CREATE TABLE import_batches (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      imported_at TEXT,
      source_type TEXT,
      file_name TEXT,
      notes TEXT
    );''');

    await db.execute('''
    CREATE TABLE mappings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      counterparty TEXT,
      account_no TEXT,
      category_id INTEGER,
      created_at TEXT,
      created_by TEXT,
      last_used_at TEXT,
      UNIQUE(counterparty, account_no)
    );''');

    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      account_id INTEGER,
      import_batch_id INTEGER,
      mapping_id INTEGER,
      date TEXT,
      description TEXT,
      amount REAL,
      currency TEXT,
      type TEXT,
      category_id INTEGER,
      tags TEXT,
      note TEXT,
      photo_path TEXT
    );''');

    // Insert a default account and some categories for demo
    await db.insert('accounts', {'name': 'Primary', 'account_number': 'NL00BANK0000', 'currency': 'EUR', 'is_primary': 1, 'balance': 0});
    await db.insert('categories', {'name': 'Groceries'});
    await db.insert('categories', {'name': 'Salary'});
  }

  // simple helpers
  Future<int> insertTransaction(Map<String, dynamic> tx) async {
    final db = await database;
    return await db.insert('transactions', tx);
  }

  Future<int> insertImportBatch(Map<String, dynamic> batch) async {
    final db = await database;
    return await db.insert('import_batches', batch);
  }

  Future<List<Map<String, dynamic>>> findMapping(String counterparty, String? accountNo) async {
    final db = await database;
    final List<Map<String, dynamic>> res = await db.query('mappings',
      where: 'counterparty = ? AND (account_no IS ? OR account_no = ?)',
      whereArgs: [counterparty, accountNo, accountNo]);
    return res;
  }

  Future<int> insertMapping(Map<String, dynamic> m) async {
    final db = await database;
    return await db.insert('mappings', m, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUnmappedCounterparties(int importBatchId) async {
    final db = await database;
    final q = await db.rawQuery('''
      SELECT DISTINCT description as counterparty
      FROM transactions
      WHERE import_batch_id = ? AND (mapping_id IS NULL OR category_id IS NULL)
    ''', [importBatchId]);
    return q;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<int> updateTransactionsByCounterparty(int importBatchId, String counterparty, int mappingId, int categoryId) async {
    final db = await database;
    return await db.update('transactions',
      {'mapping_id': mappingId, 'category_id': categoryId},
      where: 'import_batch_id = ? AND description = ?',
      whereArgs: [importBatchId, counterparty]
    );
  }

  Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 50}) async {
    final db = await database;
    return await db.query('transactions', orderBy: 'date DESC', limit: limit);
  }
}
