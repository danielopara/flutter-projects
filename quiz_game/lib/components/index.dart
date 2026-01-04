import 'package:flutter/material.dart';

class Index extends StatelessWidget {
  const Index({super.key, required this.indexData});

  final Map<String, Object> indexData;

  Color getNumberColor(Map<String, Object> data) {
    return data['correct_answer'] == data['selected_answer']
        ? Colors.green
        : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 29,
      height: 29,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: getNumberColor(indexData),
      ),

      child: Text(((indexData["question_index"] as int) + 1).toString()),
    );
  }
}
