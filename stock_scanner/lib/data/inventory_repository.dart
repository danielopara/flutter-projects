import 'package:sqflite/sqlite_api.dart';
import 'package:stock_scanner/data/app_database.dart';
import 'package:stock_scanner/models/item.dart';
import 'package:stock_scanner/models/movement.dart';

class InventoryRepository {
  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<Item>> allItems({String search = ''}) async {
    final db = await _db;
    final rows = search.trim().isEmpty
        ? await db.query('items', orderBy: 'name COLLATE NOCASE ASC')
        : await db.query(
            'items',
            where: 'name LIKE ? OR sku LIKE ? or barcode LIKE ?',
            whereArgs: List.filled(3, '%${search.trim()}%'),
            orderBy: 'name COLLATE NOCASE ASC',
          );
    return rows.map(Item.fromMap).toList();
  }

  Future<Item?> findById(String id) async {
    final db = await _db;
    final rows = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Item.fromMap(rows.first);
  }

  Future<Item?> findByName(String name) async {
    final db = await _db;
    final rows = await db.query(
      'items',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    return rows.isEmpty ? null : Item.fromMap(rows.first);
  }

  Future<Item?> findByBarcode(String barcode) async {
    final db = await _db;
    final rows = await db.query(
      'items',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    return rows.isEmpty ? null : Item.fromMap(rows.first);
  }

  Future<void> upsertItem(Item item) async {
    final db = await _db;
    await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> createItem(Item item) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert('items', item.toMap());
      if (item.quantity != 0) {
        await txn.insert(
          'movements',
          Movement(
            id: _newId(),
            itemId: item.id,
            type: MovementType.initial,
            delta: item.quantity,
            balanceAfter: item.quantity,
            createdAt: DateTime.now(),
          ).toMap(),
        );
      }
    });
  }

  Future<void> deleteItem(String id) async {
    final db = await _db;
    await db.delete('items', where: 'id=?', whereArgs: [id]);
  }

  Future<Item> applyMovement({
    required String itemId,
    required double delta,
    required MovementType type,
    String note = '',
  }) async {
    final db = await _db;
    return db.transaction<Item>((txn) async {
      final rows = await txn.query(
        'items',
        where: 'id = ?',
        whereArgs: [itemId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw StateError('Item $itemId not found');
      }
      final current = Item.fromMap(rows.first);
      final newQuantity = current.quantity + delta;
      final updated = current.copyWith(
        quantity: newQuantity,
        updatedAt: DateTime.now(),
      );
      await txn.update(
        'items',
        updated.toMap(),
        where: 'id=?',
        whereArgs: [itemId],
      );

      await txn.insert(
        'movements',
        Movement(
          id: _newId(),
          itemId: itemId,
          type: type,
          delta: delta,
          balanceAfter: newQuantity,
          createdAt: DateTime.now(),
          note: note,
        ).toMap(),
      );
      return updated;
    });
  }

  Future<List<Movement>> movementsFor(String itemId) async {
    final db = await _db;
    final rows = await db.query(
      'movements',
      where: 'item_id=?',
      whereArgs: [itemId],
      orderBy: 'created_at DESC',
    );
    return rows.map(Movement.fromMap).toList();
  }

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
