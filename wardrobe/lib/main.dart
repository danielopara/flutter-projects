import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wardrobe/app.dart';
import 'package:wardrobe/data/garment_store.dart';
import 'package:wardrobe/state/wardrobe_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final docs = await getApplicationDocumentsDirectory();
  final store = GarmentStore(Directory(p.join(docs.path, 'wardrobe')));

  runApp(
    ProviderScope(
      overrides: [garmentStoreProvider.overrideWithValue(store)],
      child: const WardrobeApp(),
    ),
  );
}
