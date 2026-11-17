import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:wardrobe/models/garment.dart';

/// Everything the app persists: the garments plus the app-lock preference.
class WardrobeData {
  final List<Garment> garments;
  final bool appLock;

  const WardrobeData({this.garments = const [], this.appLock = false});

  WardrobeData copyWith({List<Garment>? garments, bool? appLock}) =>
      WardrobeData(
        garments: garments ?? this.garments,
        appLock: appLock ?? this.appLock,
      );

  Map<String, dynamic> toJson() => {
    'version': 1,
    'appLock': appLock,
    'garments': garments.map((g) => g.toJson()).toList(),
  };

  factory WardrobeData.fromJson(Map<String, dynamic> json) => WardrobeData(
    appLock: json['appLock'] as bool? ?? false,
    garments: (json['garments'] as List? ?? const [])
        .map((e) => Garment.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// Stores the wardrobe as a JSON file and garment photos as files, all under
/// [root] (the app documents directory in production, a temp dir in tests).
class GarmentStore {
  GarmentStore(this.root);

  final Directory root;
  static const _uuid = Uuid();

  File get _file => File(p.join(root.path, 'wardrobe.json'));
  Directory get _images => Directory(p.join(root.path, 'images'));

  Future<WardrobeData> load() async {
    final file = _file;
    if (!await file.exists()) return const WardrobeData();
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return const WardrobeData();
    return WardrobeData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Writes to a temp file then renames it, so a crash mid-write can never
  /// leave a half-written (unreadable) wardrobe file behind.
  Future<void> save(WardrobeData data) async {
    await root.create(recursive: true);
    final tmp = File('${_file.path}.tmp');
    await tmp.writeAsString(jsonEncode(data.toJson()), flush: true);
    await tmp.rename(_file.path);
  }

  /// Copies a picked photo into the store and returns its stored file name.
  Future<String> importImage(String sourcePath) async {
    await _images.create(recursive: true);
    final name = '${_uuid.v4()}${p.extension(sourcePath).toLowerCase()}';
    await File(sourcePath).copy(p.join(_images.path, name));
    return name;
  }

  File imageFile(String name) => File(p.join(_images.path, name));

  Future<void> deleteImage(String? name) async {
    if (name == null) return;
    final file = imageFile(name);
    if (await file.exists()) await file.delete();
  }

  /// Deletes photos no garment references (e.g. the app was closed while an
  /// "Undo delete" snackbar was still showing).
  Future<void> pruneImages({required Set<String> keep}) async {
    if (!await _images.exists()) return;
    await for (final entity in _images.list()) {
      if (entity is File && !keep.contains(p.basename(entity.path))) {
        await entity.delete();
      }
    }
  }

  String newId() => _uuid.v4();
}
