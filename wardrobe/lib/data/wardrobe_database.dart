import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'wardrobe_database.g.dart';

/// One garment. [colors] is a JSON list of palette names; [position] keeps
/// the order garments were added in.
@DataClassName('GarmentRow')
class Garments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get colors => text()();
  IntColumn get quantity => integer()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Garment photos, keyed by the name a garment stores in `imagePath`.
@DataClassName('PhotoRow')
class Photos extends Table {
  TextColumn get name => text()();
  BlobColumn get bytes => blob()();

  @override
  Set<Column> get primaryKey => {name};
}

/// Preferences such as app lock, as key/value pairs.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// The wardrobe's SQLite database.
///
/// On iOS, Android and macOS it is a file in the app documents directory. On
/// the web, SQLite runs as WebAssembly (`web/sqlite3.wasm`, driven by
/// `web/drift_worker.js`) and keeps the database in the browser.
@DriftDatabase(tables: [Garments, Photos, Settings])
class WardrobeDatabase extends _$WardrobeDatabase {
  WardrobeDatabase(super.executor);

  /// Opens the database where the platform keeps it.
  WardrobeDatabase.open()
    : super(
        driftDatabase(
          name: 'wardrobe',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 1;
}
