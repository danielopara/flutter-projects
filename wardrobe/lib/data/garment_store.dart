import 'dart:convert';
import 'dart:ui' as ui;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture, immutable;
import 'package:flutter/painting.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:wardrobe/data/wardrobe_database.dart';
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

/// A wardrobe saved by a version of the app from before SQLite.
class LegacyWardrobe {
  const LegacyWardrobe({
    required this.data,
    required this.photos,
    required this.markImported,
  });

  final WardrobeData data;

  /// Photo bytes by stored name.
  final Map<String, Uint8List> photos;

  /// Called once the wardrobe is in SQLite, so it is not imported twice.
  final Future<void> Function() markImported;
}

/// Reads the wardrobe and its photos from the [WardrobeDatabase].
class GarmentStore {
  GarmentStore(this.db, {this.readLegacy});

  final WardrobeDatabase db;

  /// Finds a pre-SQLite wardrobe to import on first load, if any.
  final Future<LegacyWardrobe?> Function()? readLegacy;

  static const _uuid = Uuid();
  static const _appLockKey = 'appLock';

  Future<WardrobeData> load() async {
    await _importLegacy();
    final rows = await (db.select(
      db.garments,
    )..orderBy([(t) => OrderingTerm(expression: t.position)])).get();
    final lock = await (db.select(
      db.settings,
    )..where((t) => t.key.equals(_appLockKey))).getSingleOrNull();
    return WardrobeData(
      garments: [for (final row in rows) _fromRow(row)],
      appLock: lock?.value == 'true',
    );
  }

  /// Replaces the stored wardrobe with [data] in one transaction.
  Future<void> save(WardrobeData data) => db.transaction(() async {
    await db.delete(db.garments).go();
    await db.batch((b) {
      b.insertAll(db.garments, [
        for (final (i, g) in data.garments.indexed) _toRow(g, i),
      ]);
      b.insert(
        db.settings,
        SettingsCompanion.insert(key: _appLockKey, value: '${data.appLock}'),
        mode: InsertMode.insertOrReplace,
      );
    });
  });

  /// Stores a picked photo and returns its stored name. [fileName] is the
  /// picked file's name; only its extension is kept.
  Future<String> importImage(
    Uint8List bytes, {
    required String fileName,
  }) async {
    final name = '${newId()}${p.extension(fileName).toLowerCase()}';
    await db
        .into(db.photos)
        .insert(PhotosCompanion.insert(name: name, bytes: bytes));
    return name;
  }

  /// The photo stored as [name]. Loads lazily when first painted.
  ImageProvider imageProvider(String name) => StoredPhoto(this, name);

  /// The bytes of the photo stored as [name], or null if there is none.
  Future<Uint8List?> photoBytes(String name) async {
    final row = await (db.select(
      db.photos,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
    return row?.bytes;
  }

  Future<void> deleteImage(String? name) async {
    if (name == null) return;
    await (db.delete(db.photos)..where((t) => t.name.equals(name))).go();
  }

  /// Deletes photos no garment references (e.g. the app was closed while an
  /// "Undo delete" snackbar was still showing).
  Future<void> pruneImages({required Set<String> keep}) async {
    await (db.delete(db.photos)..where((t) => t.name.isNotIn(keep))).go();
  }

  String newId() => _uuid.v4();

  /// Copies a pre-SQLite wardrobe in, but only into an empty database.
  Future<void> _importLegacy() async {
    final legacy = await readLegacy?.call();
    if (legacy == null) return;
    final count = db.garments.id.count();
    final existing = await (db.selectOnly(
      db.garments,
    )..addColumns([count])).map((r) => r.read(count)!).getSingle();
    if (existing == 0) {
      await db.transaction(() async {
        await db.batch((b) {
          b.insertAll(db.photos, [
            for (final MapEntry(:key, :value) in legacy.photos.entries)
              PhotosCompanion.insert(name: key, bytes: value),
          ], mode: InsertMode.insertOrReplace);
        });
        await save(legacy.data);
      });
    }
    await legacy.markImported();
  }

  static Garment _fromRow(GarmentRow row) => Garment(
    id: row.id,
    name: row.name,
    category: Category.values.byName(row.category),
    colors: (jsonDecode(row.colors) as List).cast<String>(),
    quantity: row.quantity,
    imagePath: row.imagePath,
  );

  static GarmentsCompanion _toRow(Garment g, int position) =>
      GarmentsCompanion.insert(
        id: g.id,
        name: g.name,
        category: g.category.name,
        colors: jsonEncode(g.colors),
        quantity: g.quantity,
        imagePath: Value(g.imagePath),
        position: position,
      );
}

/// A garment photo read from the database when it is first painted.
@immutable
class StoredPhoto extends ImageProvider<StoredPhoto> {
  const StoredPhoto(this.store, this.name);

  final GarmentStore store;
  final String name;

  @override
  Future<StoredPhoto> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    StoredPhoto key,
    ImageDecoderCallback decode,
  ) => MultiFrameImageStreamCompleter(
    codec: _load(decode),
    scale: 1,
    debugLabel: 'StoredPhoto($name)',
  );

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await store.photoBytes(name);
    if (bytes == null) throw StateError('Photo $name is missing');
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is StoredPhoto &&
      identical(other.store, store) &&
      other.name == name;

  @override
  int get hashCode => Object.hash(identityHashCode(store), name);
}
