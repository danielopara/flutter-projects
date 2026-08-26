import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../screens/item_edit_screen.dart';
import '../state/inventory_store.dart';

class ScanResultSheet extends StatefulWidget {
  const ScanResultSheet({super.key, required this.barcode, this.item});

  final String barcode;
  final Item? item;

  @override
  State<ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends State<ScanResultSheet> {
  late final Item? _item = widget.item;
  double _delta = 1;
  bool _busy = false;

  Future<void> _apply(double sign) async {
    if (_item == null || _busy) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final store = context.read<InventoryStore>();

    setState(() => _busy = true);

    try {
      final updated = await store.adjust(
        itemId: _item.id,
        delta: _delta * sign,
        note: 'Scanned',
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${updated.name}: ${updated.quantity.toStringAsFixed(0)} ${updated.unit}',
          ),
          duration: const Duration(milliseconds: 1200),
        ),
      );
      navigator.pop(true);
    } catch (e) {
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _createItem() async {
    final navigator = Navigator.of(context);

    final created = await navigator.push<bool>(
      MaterialPageRoute(
        builder: (_) => ItemEditScreen(prefilledBarcode: widget.barcode),
      ),
    );

    if (!mounted) return;
    navigator.pop(created == true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = _item;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.barcode,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          if (item == null) ...[
            Text('Unknown barcode', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'No item is registered against this code yet.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _createItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Create item'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(item.name, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'In stock: ${item.quantity.toStringAsFixed(0)} ${item.unit}'
              '${item.location.isEmpty ? '' : '  •  ${item.location}'}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final q in [1.0, 5.0, 10.0])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(q.toStringAsFixed(0)),
                      selected: _delta == q,
                      onSelected: (_) => setState(() => _delta = q),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : () => _apply(-1),
                    icon: const Icon(Icons.remove),
                    label: Text('Out ${_delta.toStringAsFixed(0)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : () => _apply(1),
                    icon: const Icon(Icons.add),
                    label: Text('In ${_delta.toStringAsFixed(0)}'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
