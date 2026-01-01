import 'package:flutter/material.dart';
import 'package:quiz_game/quiz_screen.dart';
import 'package:quiz_game/start_screen.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() {
    return _QuizState();
  }
}

class _QuizState extends State<Quiz> {
  var activeScreen = 'start-screen';

  void changeScreen() {
    setState(() {
      activeScreen = 'questions-screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget = StartScreen(changeScreen);

    if (activeScreen == 'questions-screen') {
      screenWidget = const QuizScreen();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Color.fromARGB(255, 2, 129, 234)],
          ),
        ),
        child: screenWidget,
      ),
    );
  }
}
