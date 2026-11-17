import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wardrobe/app.dart';
import 'package:wardrobe/data/open_garment_store.dart';
import 'package:wardrobe/state/wardrobe_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = openGarmentStore();

  runApp(
    ProviderScope(
      overrides: [garmentStoreProvider.overrideWithValue(store)],
      child: const WardrobeApp(),
    ),
  );
}
