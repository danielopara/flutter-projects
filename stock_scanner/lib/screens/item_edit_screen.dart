import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:stock_scanner/models/item.dart';
import 'package:stock_scanner/state/inventory_store.dart';

class ItemEditScreen extends StatefulWidget {
  const ItemEditScreen({super.key, this.item, this.prefilledBarcode});

  final Item? item;
  final String? prefilledBarcode;

  @override
  State<StatefulWidget> createState() => _ItemEditScreenState();
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
  bool get _barcodeLocked =>
      _isEditing || (widget.prefilledBarcode?.isNotEmpty ?? false);

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _unitController.dispose();
    _skuController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _barcodeController = TextEditingController(
      text: item?.barcode ?? widget.prefilledBarcode ?? '',
    );
    _nameController = TextEditingController(text: item?.name ?? '');

    _skuController = TextEditingController(text: item?.sku ?? '');
    _locationController = TextEditingController(text: item?.location ?? '');
    _thresholdController = TextEditingController(
      text: (item?.lowStockThreshold ?? 0).toStringAsFixed(0),
    );
    _quantityController = TextEditingController(
      text: item == null ? '0' : item.quantity.toStringAsFixed(0),
    );
    _unitController = TextEditingController(text: item?.unit ?? 'pcs');
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

    setState(() {
      _saving = true;
    });

    final item = Item(
      id: widget.item?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      barcode: _barcodeController.text.trim(),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Item' : 'New Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _barcodeController,
              validator: _requiredValidator,
              readOnly: _barcodeLocked,
              decoration: InputDecoration(
                labelText: 'Barcode',
                border: const OutlineInputBorder(),
                filled: _barcodeLocked,
                helperText: _barcodeLocked
                    ? 'Scanned - cannot be changed'
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              autocorrect: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              validator: _requiredValidator,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU (optional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    readOnly: _isEditing,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: _numberValidator,
                    decoration: InputDecoration(
                      labelText: _isEditing ? 'Quantity' : 'Opening quantity',
                      border: const OutlineInputBorder(),
                      filled: _isEditing,
                      helperText: _isEditing ? 'Change via scan' : null,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _thresholdController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _numberValidator,
              decoration: const InputDecoration(
                labelText: 'Low stock threshold',
                helperText: '0 disables the warning',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_isEditing ? 'Save changes' : 'Create Item'),
            ),
          ],
        ),
      ),
    );
  }
}
