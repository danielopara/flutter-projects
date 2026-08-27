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

    final totalUnits = items.fold<double>(0, (sum, i) => sum + i.quantity);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search name, SKU or barcode',
                  border: InputBorder.none,
                  filled: false,
                  isDense: true,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Stock'),
                  if (items.isNotEmpty)
                    Text(
                      '${items.length} items · '
                      '${totalUnits.toStringAsFixed(0)} units',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
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
            _LowStockBanner(count: store.lowStockCount),
          Expanded(
            child: switch ((store.loading, items.isEmpty)) {
              (true, _) => const Center(child: CircularProgressIndicator()),
              (false, true) => _EmptyState(
                searching: store.search.isNotEmpty,
                onAdd: _openNewItem,
              ),
              _ => RefreshIndicator(
                onRefresh: () => store.refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: items.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ItemCard(
                      item: items[i],
                      onTap: () => _openDetail(items[i]),
                    ),
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

/// A card row. The quantity is the loudest thing on it, because that's
/// what you're actually looking for when you open this screen.
class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.onTap});

  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final low = item.isLowStock;

    // Location is what you care about; SKU is the fallback.
    // The barcode is deliberately not shown — 13 digits of noise.
    final subtitle = item.location.isNotEmpty
        ? item.location
        : (item.sku.isNotEmpty ? item.sku : null);

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Status edge. Reads at a glance without shouting.
              Container(
                width: 4,
                color: low
                    ? scheme.error
                    : scheme.primary.withValues(alpha: 0.35),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    item.location.isNotEmpty
                                        ? Icons.place_outlined
                                        : Icons.tag_outlined,
                                    size: 13,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (low) ...[
                              const SizedBox(height: 5),
                              Text(
                                'Low stock',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _QuantityPill(item: item, low: low),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityPill extends StatelessWidget {
  const _QuantityPill({required this.item, required this.low});

  final Item item;
  final bool low;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: low ? scheme.errorContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            item.quantity.toStringAsFixed(0),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1,
              color: low ? scheme.onErrorContainer : scheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            item.unit,
            style: theme.textTheme.labelSmall?.copyWith(
              color: low
                  ? scheme.onErrorContainer.withValues(alpha: 0.8)
                  : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  const _LowStockBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: scheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count ${count == 1 ? 'item' : 'items'} at or below reorder level',
              style: TextStyle(
                color: scheme.onErrorContainer,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
    final scheme = theme.colorScheme;

    if (searching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: scheme.outline),
            const SizedBox(height: 14),
            Text('No matches', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Try a different term',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text('No items yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Scan a barcode to get started, or add\nan item manually.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add manually'),
            ),
          ],
        ),
      ),
    );
  }
}
