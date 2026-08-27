import 'package:barcode_widget/barcode_widget.dart';
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
    final scheme = Theme.of(context).colorScheme;

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
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
              minimumSize: const Size(88, 44),
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
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: _edit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _StockCard(item: _item, dateFormat: _dateFormat),
          const SizedBox(height: 12),
          _BarcodeCard(barcode: _item.barcode),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'MOVEMENT HISTORY',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
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
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Could not load history: ${snapshot.error}',
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                );
              }

              final movements = snapshot.data ?? [];
              if (movements.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'No movements yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < movements.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: 60,
                          color: scheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      _MovementRow(
                        movement: movements[i],
                        dateFormat: _dateFormat,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Headline quantity plus the metadata rows.
class _StockCard extends StatelessWidget {
  const _StockCard({required this.item, required this.dateFormat});

  final Item item;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final low = item.isLowStock;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.quantity.toStringAsFixed(0),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: low ? scheme.error : scheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  item.unit,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Spacer(),
              if (low)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LOW',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          if (low) ...[
            const SizedBox(height: 6),
            Text(
              'At or below reorder level '
              '(${item.lowStockThreshold.toStringAsFixed(0)})',
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
          const SizedBox(height: 20),
          if (item.sku.isNotEmpty)
            _DetailRow(icon: Icons.tag_outlined, label: 'SKU', value: item.sku),
          if (item.location.isNotEmpty)
            _DetailRow(
              icon: Icons.place_outlined,
              label: 'Location',
              value: item.location,
            ),
          _DetailRow(
            icon: Icons.schedule,
            label: 'Updated',
            value: dateFormat.format(item.updatedAt),
          ),
        ],
      ),
    );
  }
}

/// Renders the actual scannable barcode.
///
/// EAN-13 is strict: 13 digits with a valid check digit, and the widget
/// throws on anything else. Anything that doesn't fit falls back to
/// Code 128, which accepts arbitrary alphanumeric data.
class _BarcodeCard extends StatelessWidget {
  const _BarcodeCard({required this.barcode});

  final String barcode;

  bool get _looksLikeEan13 =>
      barcode.length == 13 && RegExp(r'^\d{13}$').hasMatch(barcode);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // White plate behind the bars. Scanners need dark bars on a
          // light background — rendering white-on-dark in dark mode
          // produces a barcode no reader will pick up.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: BarcodeWidget(
              barcode: _looksLikeEan13 ? Barcode.ean13() : Barcode.code128(),
              data: barcode,
              height: 72,
              drawText: true,
              color: Colors.black,
              errorBuilder: (context, error) => SizedBox(
                height: 72,
                child: Center(
                  child: Text(
                    barcode,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _looksLikeEan13 ? 'EAN-13' : 'Code 128',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({required this.movement, required this.dateFormat});

  final Movement movement;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final positive = movement.delta >= 0;

    // Material 3 has no semantic "success" role, so this is a literal.
    // It won't follow your seed colour if you change it.
    const inColor = Color(0xFF3FA96B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (positive ? inColor : scheme.error).withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              positive ? Icons.arrow_downward : Icons.arrow_upward,
              size: 17,
              color: positive ? inColor : scheme.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movement.type.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  movement.note.isEmpty
                      ? dateFormat.format(movement.createdAt)
                      : '${dateFormat.format(movement.createdAt)} · ${movement.note}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${positive ? '+' : ''}${movement.delta.toStringAsFixed(0)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: positive ? inColor : scheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '→ ${movement.balanceAfter.toStringAsFixed(0)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
