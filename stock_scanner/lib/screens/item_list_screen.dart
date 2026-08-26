import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../export.dart';
import '../models/item.dart';
import '../state/inventory_store.dart';
import 'item_detail_screen.dart';
import 'item_edit_screen.dart';
import 'scanner_screen.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      context.read<InventoryStore>().setSearch(value);
    });
  }

  void _closeSearch() {
    _debounce?.cancel();
    _searchController.clear();
    context.read<InventoryStore>().setSearch('');
    setState(() => _searching = false);
  }

  Future<void> _openScanner() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ScannerScreen()));
    if (!mounted) return;
    await context.read<InventoryStore>().refresh();
  }

  Future<void> _openNewItem() async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const ItemEditScreen()));
  }

  Future<void> _openDetail(Item item) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)));
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    final items = context.read<InventoryStore>().items;

    if (items.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Nothing to export yet')),
      );
      return;
    }

    try {
      await exportItemsCsv(items);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<InventoryStore>();
    final theme = Theme.of(context);
    final items = store.items;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search name, SKU or barcode',
                  border: InputBorder.none,
                ),
              )
            : const Text('Stock'),
        actions: [
          if (_searching)
            IconButton(icon: const Icon(Icons.close), onPressed: _closeSearch)
          else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _searching = true),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add item manually',
              onPressed: _openNewItem,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'export') _export();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'export', child: Text('Export CSV')),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (store.lowStockCount > 0)
            Container(
              width: double.infinity,
              color: theme.colorScheme.errorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${store.lowStockCount} item(s) at or below reorder level',
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ],
              ),
            ),
          Expanded(
            child: switch ((store.loading, items.isEmpty)) {
              (true, _) => const Center(child: CircularProgressIndicator()),
              (false, true) => _EmptyState(
                searching: store.search.isNotEmpty,
                onAdd: _openNewItem,
              ),
              _ => RefreshIndicator(
                onRefresh: () => store.refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => _ItemRow(
                    item: items[i],
                    onTap: () => _openDetail(items[i]),
                  ),
                ),
              ),
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanner,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan'),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final low = item.isLowStock;

    return ListTile(
      onTap: onTap,
      title: Text(item.name),
      subtitle: Text(
        [
          item.sku.isEmpty ? item.barcode : item.sku,
          if (item.location.isNotEmpty) item.location,
        ].join('  •  '),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            item.quantity.toStringAsFixed(0),
            style: theme.textTheme.titleMedium?.copyWith(
              color: low ? theme.colorScheme.error : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(item.unit, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searching, required this.onAdd});

  final bool searching;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (searching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('No matches', style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text('No items yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Scan a barcode or add one manually',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
          ),
        ],
      ),
    );
  }
}
