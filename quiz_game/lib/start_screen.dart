import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen(this.changeScreen, {super.key});

  final void Function() changeScreen;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/quiz-logo.png', width: 200),
          const SizedBox(height: 80),
          const Text(
            'Learn Flutter the fun way!',
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              changeScreen();
              debugPrint('button pressed');
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
            ),
            icon: Icon(Icons.arrow_right_alt, color: Colors.white),
            label: const Text(
              'Start here!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
