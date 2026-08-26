import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/item.dart';

Future<void> exportItemsCsv(List<Item> items) async {
  final rows = <List<dynamic>>[
    ['Barcode', 'Name', 'SKU', 'Quantity', 'Unit', 'Location', 'Updated'],
    ...items.map(
      (i) => [
        i.barcode,
        i.name,
        i.sku,
        i.quantity,
        i.unit,
        i.location,
        i.updatedAt.toIso8601String(),
      ],
    ),
  ];

  final csv = const ListToCsvConverter().convert(rows);

  final dir = await getTemporaryDirectory();
  final stamp = DateTime.now().toIso8601String().split('T').first;
  final file = File('${dir.path}/stock_$stamp.csv');
  await file.writeAsString(csv);

  await Share.shareXFiles([XFile(file.path)], subject: 'Stock export $stamp');
}
