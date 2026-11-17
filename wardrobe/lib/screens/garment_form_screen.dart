import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wardrobe/models/garment.dart';
import 'package:wardrobe/state/wardrobe_providers.dart';
import 'package:wardrobe/widgets/garment_photo.dart';

/// Result returned when the user deletes the garment from the edit screen.
class GarmentDeleted {
  const GarmentDeleted(this.garment, this.index);
  final Garment garment;
  final int index;
}

/// Add a new garment ([initial] == null) or edit an existing one.
class GarmentFormScreen extends ConsumerStatefulWidget {
  const GarmentFormScreen({super.key, this.initial, this.initialCategory});

  final Garment? initial;
  final Category? initialCategory;

  @override
  ConsumerState<GarmentFormScreen> createState() => _GarmentFormScreenState();
}

class _GarmentFormScreenState extends ConsumerState<GarmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late Category _category;
  late Set<String> _colors;
  late int _quantity;
  String? _imagePath;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final g = widget.initial;
    _name = TextEditingController(text: g?.name ?? '');
    _category = g?.category ?? widget.initialCategory ?? Category.tops;
    _colors = {...?g?.colors};
    _quantity = g?.quantity ?? 1;
    _imagePath = g?.imagePath;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final sources = [
      for (final s in ImageSource.values)
        if (picker.supportsImageSource(s)) s,
    ];
    final choice = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sources.contains(ImageSource.camera))
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            if (sources.contains(ImageSource.gallery))
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from library'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            if (_imagePath != null)
              ListTile(
                leading: const Icon(Icons.hide_image_outlined),
                title: const Text('Remove photo'),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'remove') {
      setState(() => _imagePath = null);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await picker.pickImage(
        source: choice as ImageSource,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final stored = await ref
          .read(garmentStoreProvider)
          .importImage(file.path);
      if (!mounted) return;
      setState(() => _imagePath = stored);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Couldn\'t add the photo: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final notifier = ref.read(wardrobeProvider.notifier);
    final base =
        widget.initial ??
        Garment(
          id: ref.read(garmentStoreProvider).newId(),
          name: '',
          category: _category,
          colors: const [],
          quantity: 1,
        );
    final garment = base.copyWith(
      name: _name.text.trim(),
      category: _category,
      // Keep palette order so colors read consistently everywhere.
      colors: [
        for (final c in garmentPalette.keys)
          if (_colors.contains(c)) c,
      ],
      quantity: _quantity,
      imagePath: _imagePath,
      clearImage: _imagePath == null,
    );
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await notifier.upsert(garment);
      navigator.pop();
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text('Couldn\'t save: $e')));
    }
  }

  Future<void> _delete() async {
    final garment = widget.initial!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${garment.name}"?'),
        content: const Text('You can undo this right after.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final navigator = Navigator.of(context);
    final removed = await ref
        .read(wardrobeProvider.notifier)
        .delete(garment.id);
    if (removed == null) {
      navigator.pop();
      return;
    }
    navigator.pop(GarmentDeleted(removed.$1, removed.$2));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit garment' : 'Add garment'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Center(
              child: Semantics(
                button: true,
                label: _imagePath == null ? 'Add photo' : 'Change photo',
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      GarmentPhoto(
                        imagePath: _imagePath,
                        category: _category,
                        size: 160,
                        radius: 20,
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.primary,
                          child: Icon(
                            Icons.photo_camera,
                            size: 18,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. White linen shirt',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Give it a name' : null,
            ),
            const SizedBox(height: 24),
            Text('Category', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in Category.values)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18),
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Colors', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final MapEntry(key: name, value: color)
                    in garmentPalette.entries)
                  FilterChip(
                    avatar: CircleAvatar(
                      backgroundColor: color,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                    showCheckmark: false,
                    label: Text(name),
                    selected: _colors.contains(name),
                    onSelected: (on) => setState(
                      () => on ? _colors.add(name) : _colors.remove(name),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Quantity', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Decrease quantity',
                  onPressed: _quantity > 0
                      ? () => setState(() => _quantity--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Increase quantity',
                  onPressed: _quantity < 999
                      ? () => setState(() => _quantity++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check),
        label: Text(_isEditing ? 'Save changes' : 'Add to wardrobe'),
      ),
    );
  }
}
