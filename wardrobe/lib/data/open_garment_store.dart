import 'package:wardrobe/data/garment_store.dart';
import 'package:wardrobe/data/legacy_wardrobe_io.dart'
    if (dart.library.js_interop) 'package:wardrobe/data/legacy_wardrobe_web.dart';
import 'package:wardrobe/data/wardrobe_database.dart';

/// Opens the wardrobe's SQLite database, importing a pre-SQLite wardrobe on
/// first load (iOS, Android and macOS only).
GarmentStore openGarmentStore() =>
    GarmentStore(WardrobeDatabase.open(), readLegacy: readLegacyWardrobe);
