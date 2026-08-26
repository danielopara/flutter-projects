import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_scanner/screens/item_edit_screen.dart';
import 'package:stock_scanner/state/inventory_store.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ItemListScreenState();
  }
}

class _ItemListScreenState extends State<ItemListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _closeSearch() {
    _debounce?.cancel();
    _searchController.clear();
    context.read<InventoryStore>().setSearch('');
    setState(() => _searching = false);
  }

  Future<void> _openEditor() async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => ItemEditScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search name, SKU or barcode',
                  border: InputBorder.none,
                ),
              )
            : const Text('Stock'),
        actions: [
          if (_searching)
            IconButton(onPressed: _closeSearch, icon: const Icon(Icons.close))
          else ...[
            IconButton(
              onPressed: () => setState(() {
                _searching = true;
              }),
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: _openEditor,
              icon: const Icon(Icons.add),
              tooltip: 'Add item manually',
            ),
          ],
        ],
      ),
      body: Center(child: Text('Hello')),
    );
  }
}
