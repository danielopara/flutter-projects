import 'package:flutter/material.dart';

class Summary extends StatelessWidget {
  const Summary({super.key, required this.summaryData});
  final List<Map<String, Object>> summaryData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: summaryData.map((data) {
        return Row(
          children: [
            Text(((data['question_index'] as int) + 1).toString()),
            Column(children: [Text(data['question_text'] as String)]),
          ],
        );
      }).toList(),
    );
  }
}
