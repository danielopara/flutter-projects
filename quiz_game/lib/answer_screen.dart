import 'package:flutter/material.dart';
import 'package:quiz_game/data/questions.dart';
import 'package:quiz_game/summary.dart';

class AnswerScreen extends StatelessWidget {
  const AnswerScreen({super.key, required this.selectedAnswers});

  final List<String> selectedAnswers;

  List<Map<String, Object>> getSummaryData() {
    final List<Map<String, Object>> summary = [];

    for (var i = 0; i < selectedAnswers.length; i++) {
      summary.add({
        'question_index': i,
        'question_text': questions[i].question,
        'correct_answer': questions[i].answers[0],
        'selected_answer': selectedAnswers[i],
      });
    }
    print(selectedAnswers);
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Answers'),
            const SizedBox(height: 30),
            Summary(summaryData: getSummaryData()),
            TextButton(onPressed: () {}, child: Text('reset quiz')),
          ],
        ),
      ),
    );
  }
}
