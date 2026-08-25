import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = p.join(await getDatabasesPath(), 'stock_scanner.db');

    return openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createSchema,
      onUpgrade: _migrate,
    );
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        barcode TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        sku TEXT NOT NULL DEFAULT '',
        quantity REAL NOT NULL DEFAULT 0,
        unit TEXT NOT NULL DEFAULT 'pcs',
        location TEXT NOT NULL DEFAULT '',
        low_stock_threshold REAL NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE movements (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        delta REAL NOT NULL,
        balance_after REAL NOT NULL,
        type TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_movements_item ON movements (item_id, created_at DESC)',
    );
  }

  Future<void> _migrate(Database db, int oldVersion, int newVersion) async {
    // if (oldVersion < 2) {
    //   await db.execute(
    //     'ALTER TABLE items ADD COLUMN unit_cost REAL NOT NULL DEFAULT 0');
    // }
  }
}
