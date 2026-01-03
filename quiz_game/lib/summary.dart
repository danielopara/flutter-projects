import 'package:flutter/material.dart';

class Summary extends StatelessWidget {
  const Summary({super.key, required this.summaryData});
  final List<Map<String, Object>> summaryData;

  Color getNumberColor(Map<String, Object> data) {
    return data['correct_answer'] == data['selected_answer']
        ? Colors.green
        : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SizedBox(
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              children: summaryData.map((data) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 29,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: getNumberColor(data),
                      ),
                      child: Text(
                        ((data['question_index'] as int) + 1).toString(),
                        style: TextStyle(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        // textDirection: TextDirection.ltr,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['question_text'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            (data['selected_answer'] as String),
                            style: TextStyle(
                              color: const Color.fromARGB(255, 234, 231, 231),
                            ),
                          ),
                          Text(
                            (data['correct_answer'] as String),
                            style: TextStyle(
                              color: const Color.fromARGB(255, 44, 236, 51),
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
