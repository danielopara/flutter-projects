import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CHelperFunctions {
  static Color? getColor(String value) {
    return switch (value.trim().toLowerCase()) {
      'green' => Colors.green,
      'red' => Colors.red,
      'blue' => Colors.blue,
      'yellow' => Colors.yellow,
      'orange' => Colors.orange,
      'purple' => Colors.purple,
      'pink' => Colors.pink,
      'brown' => Colors.brown,
      'grey' || 'gray' => Colors.grey,
      'black' => Colors.black,
      'white' => Colors.white,
      'teal' => Colors.teal,
      'cyan' => Colors.cyan,
      'indigo' => Colors.indigo,
      'amber' => Colors.amber,
      'lime' => Colors.lime,
      _ => null,
    };
  }

  static void showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static void showAlert(String title, String message) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  static String getFormattedDate(
    DateTime date, {
    String format = 'dd MMM yyyy',
  }) {
    return DateFormat(format).format(date);
  }

  static List<T> removeDuplicates<T>(List<T> list) => list.toSet().toList();

  /// Splits widgets into rows of [rowSize]: 5 items, rowSize 2 -> 3 rows (2, 2, 1)
  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final rows = <Widget>[];
    for (var i = 0; i < widgets.length; i += rowSize) {
      final end = (i + rowSize < widgets.length) ? i + rowSize : widgets.length;
      rows.add(Row(children: widgets.sublist(i, end)));
    }
    return rows;
  }
}
