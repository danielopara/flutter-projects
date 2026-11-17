import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wardrobe/data/garment_store.dart';

/// The wardrobe saved as `wardrobe/wardrobe.json` (plus `wardrobe/images/`)
/// by versions before SQLite, or null if there is none.
///
/// Once imported, the JSON file is renamed to `wardrobe.json.imported`, so it
/// is kept as a backup but never imported again.
Future<LegacyWardrobe?> readLegacyWardrobe() async {
  final docs = await getApplicationDocumentsDirectory();
  return readLegacyWardrobeFrom(Directory(p.join(docs.path, 'wardrobe')));
}

/// [readLegacyWardrobe] for an explicit [root]; used by tests.
Future<LegacyWardrobe?> readLegacyWardrobeFrom(Directory root) async {
  final file = File(p.join(root.path, 'wardrobe.json'));
  if (!await file.exists()) return null;
  final raw = await file.readAsString();
  final data = raw.trim().isEmpty
      ? const WardrobeData()
      : WardrobeData.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  final photos = <String, Uint8List>{};
  for (final g in data.garments) {
    final name = g.imagePath;
    if (name == null) continue;
    final photo = File(p.join(root.path, 'images', name));
    if (await photo.exists()) photos[name] = await photo.readAsBytes();
  }

  return LegacyWardrobe(
    data: data,
    photos: photos,
    markImported: () => file.rename('${file.path}.imported'),
  );
}
