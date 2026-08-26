import 'package:flutter/material.dart';
import 'package:stock_scanner/data/inventory_repository.dart';
import 'package:stock_scanner/models/item.dart';
import 'package:stock_scanner/models/movement.dart';

class InventoryStore extends ChangeNotifier {
  InventoryStore(this._repo);

  final InventoryRepository _repo;

  List<Item> _items = [];
  String _search = '';
  bool _isLoading = false;

  List<Item> get items => List.unmodifiable(_items);
  String get search => _search;
  bool get loading => _isLoading;
  int get lowStockCount => _items.where((i) => i.isLowStock).length;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    _items = await _repo.allItems();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setSearch(String value) async {
    _search = value;
    _items = await _repo.allItems(search: _search);
    notifyListeners();
  }

  Future<void> refresh() async {
    _items = await _repo.allItems(search: _search);
    notifyListeners();
  }

  Future<Item?> lookUp(String barcode) => _repo.findByBarcode(barcode);

  Future<void> createItem(Item item) async {
    await _repo.createItem(item);
    await refresh();
  }

  Future<void> saveItem(Item item) async {
    await _repo.upsertItem(item);
    await refresh();
  }

  Future<void> deleteItem(String itemId) async {
    await _repo.deleteItem(itemId);
    await refresh();
  }

  Future<Item> adjust({
    required String itemId,
    required double delta,
    String note = '',
  }) async {
    final type = delta >= 0 ? MovementType.stockIn : MovementType.stockOut;
    final updated = await _repo.applyMovement(
      itemId: itemId,
      delta: delta,
      type: type,
    );
    await refresh();
    return updated;
  }

  Future<List<Movement>> historyFor(String itemId) =>
      _repo.movementsFor(itemId);
}
