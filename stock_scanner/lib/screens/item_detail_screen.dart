import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/movement.dart';
import '../state/inventory_store.dart';
import 'item_edit_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.item});

  final Item item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Item _item = widget.item;
  late Future<List<Movement>> _history;

  final _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _history = context.read<InventoryStore>().historyFor(_item.id);
  }

  void _reload() {
    final store = context.read<InventoryStore>();
    setState(() {
      _item = store.items.firstWhere(
        (i) => i.id == _item.id,
        orElse: () => _item,
      );
      _history = store.historyFor(_item.id);
    });
  }

  Future<void> _edit() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ItemEditScreen(item: _item)),
    );
    if (!mounted || changed != true) return;
    _reload();
  }

  Future<void> _confirmDelete() async {
    final navigator = Navigator.of(context);
    final store = context.read<InventoryStore>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text(
          '"${_item.name}" and its entire movement history will be removed. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await store.deleteItem(_item.id);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_item.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _edit),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _item.quantity.toStringAsFixed(0),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: _item.isLowStock
                              ? theme.colorScheme.error
                              : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _item.unit,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  if (_item.isLowStock) ...[
                    const SizedBox(height: 4),
                    Text(
                      'At or below reorder level '
                      '(${_item.lowStockThreshold.toStringAsFixed(0)})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                  const Divider(height: 28),
                  _DetailRow(label: 'Barcode', value: _item.barcode),
                  if (_item.sku.isNotEmpty)
                    _DetailRow(label: 'SKU', value: _item.sku),
                  if (_item.location.isNotEmpty)
                    _DetailRow(label: 'Location', value: _item.location),
                  _DetailRow(
                    label: 'Updated',
                    value: _dateFormat.format(_item.updatedAt),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text('Movement history', style: theme.textTheme.titleMedium),
          ),
          FutureBuilder<List<Movement>>(
            future: _history,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text('Could not load history: ${snapshot.error}'),
                  ),
                );
              }

              final movements = snapshot.data ?? [];
              if (movements.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No movements yet',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: movements.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final m = movements[i];
                  final positive = m.delta >= 0;

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      positive ? Icons.arrow_downward : Icons.arrow_upward,
                      color: positive ? Colors.green : theme.colorScheme.error,
                      size: 20,
                    ),
                    title: Text(m.type.label),
                    subtitle: Text(
                      m.note.isEmpty
                          ? _dateFormat.format(m.createdAt)
                          : '${_dateFormat.format(m.createdAt)} · ${m.note}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${positive ? '+' : ''}${m.delta.toStringAsFixed(0)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: positive
                                ? Colors.green
                                : theme.colorScheme.error,
                          ),
                        ),
                        Text(
                          '→ ${m.balanceAfter.toStringAsFixed(0)}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
