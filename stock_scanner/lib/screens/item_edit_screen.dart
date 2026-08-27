import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/item.dart';
import '../state/inventory_store.dart';
import 'scanner_screen.dart';

class ItemEditScreen extends StatefulWidget {
  const ItemEditScreen({super.key, this.item, this.prefilledBarcode});

  final Item? item;
  final String? prefilledBarcode;

  @override
  State<ItemEditScreen> createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends State<ItemEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _barcodeController;
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _locationController;
  late final TextEditingController _thresholdController;

  bool _saving = false;

  bool get _isEditing => widget.item != null;

  /// Locked when editing, or when the barcode arrived from a scan.
  bool get _barcodeLocked =>
      _isEditing || (widget.prefilledBarcode?.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _barcodeController = TextEditingController(
      text: item?.barcode ?? widget.prefilledBarcode ?? '',
    );
    _nameController = TextEditingController(text: item?.name ?? '');
    _skuController = TextEditingController(text: item?.sku ?? '');
    _quantityController = TextEditingController(
      text: item == null ? '0' : item.quantity.toStringAsFixed(0),
    );
    _unitController = TextEditingController(text: item?.unit ?? 'pcs');
    _locationController = TextEditingController(text: item?.location ?? '');
    _thresholdController = TextEditingController(
      text: (item?.lowStockThreshold ?? 0).toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _skuController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _locationController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final messenger = ScaffoldMessenger.of(context);
    final store = context.read<InventoryStore>();

    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScannerScreen.pick()),
    );

    if (!mounted || code == null || code.isEmpty) return;

    // Catch the collision here rather than letting UNIQUE throw on save.
    final existing = await store.lookUp(code);
    if (!mounted) return;

    if (existing != null && existing.id != widget.item?.id) {
      messenger.showSnackBar(
        SnackBar(content: Text('Already registered to "${existing.name}"')),
      );
      return;
    }

    setState(() => _barcodeController.text = code);
  }

  String? _requiredValidator(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (double.tryParse(value.trim()) == null) return 'Enter a number';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final store = context.read<InventoryStore>();

    setState(() => _saving = true);

    final item = Item(
      id: widget.item?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      sku: _skuController.text.trim(),
      quantity: double.parse(_quantityController.text.trim()),
      unit: _unitController.text.trim().isEmpty
          ? 'pcs'
          : _unitController.text.trim(),
      location: _locationController.text.trim(),
      lowStockThreshold: double.parse(_thresholdController.text.trim()),
      updatedAt: DateTime.now(),
    );

    try {
      if (_isEditing) {
        await store.saveItem(item);
      } else {
        await store.createItem(item);
      }
      navigator.pop(true);
    } on DatabaseException catch (e) {
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.isUniqueConstraintError()
                ? 'That barcode is already registered to another item'
                : 'Could not save: $e',
          ),
        ),
      );
    } catch (e) {
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit item' : 'New item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const _SectionLabel('Identity'),
            TextFormField(
              controller: _barcodeController,
              readOnly: _barcodeLocked,
              validator: _requiredValidator,
              decoration: InputDecoration(
                labelText: 'Barcode',
                hintText: _barcodeLocked ? null : 'Scan or type',
                prefixIcon: const Icon(Icons.qr_code_2, size: 20),
                helperText: _barcodeLocked
                    ? 'Scanned — cannot be changed'
                    : null,
                suffixIcon: _barcodeLocked
                    ? Icon(Icons.lock_outline, size: 18, color: scheme.outline)
                    : IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        tooltip: 'Scan barcode',
                        onPressed: _scanBarcode,
                      ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameController,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              validator: _requiredValidator,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Nivea roll-on 50ml',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU',
                hintText: 'Optional internal code',
              ),
            ),

            const SizedBox(height: 28),
            const _SectionLabel('Stock'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _quantityController,
                    readOnly: _isEditing,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _numberValidator,
                    decoration: InputDecoration(
                      labelText: _isEditing ? 'Quantity' : 'Opening quantity',
                      helperText: _isEditing ? 'Change by scanning' : null,
                      suffixIcon: _isEditing
                          ? Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: scheme.outline,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Optional — shelf, room, store',
                prefixIcon: Icon(Icons.place_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _thresholdController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _numberValidator,
              decoration: const InputDecoration(
                labelText: 'Low stock threshold',
                helperText: '0 disables the warning',
                prefixIcon: Icon(Icons.notifications_none, size: 20),
              ),
            ),

            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_isEditing ? 'Save changes' : 'Create item'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 2),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
