import 'package:flutter/material.dart';
import 'package:quiz_game/answer_button.dart';
import 'package:quiz_game/data/questions.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({required this.onSelectedAnswer, super.key});

  final void Function(String answer) onSelectedAnswer;

  @override
  State<QuizScreen> createState() {
    return _QuizScreenState();
  }
}

class _QuizScreenState extends State<QuizScreen> {
  var currentQuestionIndex = 0;
  String? selectedAnswer;
  List<String> shuffledAnswers = [];

  @override
  void initState() {
    super.initState();
    shuffledAnswers = questions[currentQuestionIndex].getShuffledAnswers();
  }

  void answerQuestion(String answer) {
    widget.onSelectedAnswer(answer);
    setState(() {
      currentQuestionIndex++;
      selectedAnswer = null;
      if (currentQuestionIndex < questions.length) {
        shuffledAnswers = questions[currentQuestionIndex].getShuffledAnswers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];

    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentQuestion.question,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ...shuffledAnswers.map((answer) {
              return AnswerButton(
                answerText: answer,
                isSelected: selectedAnswer == answer,
                onTap: () {
                  if (selectedAnswer == answer) {
                    answerQuestion(answer);
                  } else {
                    setState(() {
                      selectedAnswer = answer;
                    });
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
