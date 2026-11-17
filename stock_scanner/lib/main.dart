import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:stock_scanner/data/inventory_repository.dart';
import 'package:stock_scanner/screens/item_list_screen.dart';
import 'package:stock_scanner/state/inventory_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // On the web, SQLite runs from sqlite3.wasm (see sqflite_common_ffi_web).
  if (kIsWeb) databaseFactory = databaseFactoryFfiWebNoWebWorker;
  runApp(StockScannerApp());
}

class StockScannerApp extends StatelessWidget {
  const StockScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryStore(InventoryRepository())..init(),
      child: MaterialApp(
        title: 'Stock Scanner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const ItemListScreen(),
      ),
    );
  }
}
